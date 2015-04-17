Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2576B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 18:37:38 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so138813417pab.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 15:37:38 -0700 (PDT)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id mp9si14528225pbc.124.2015.04.17.15.37.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 15:37:37 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so138812984pab.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 15:37:37 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <553144EB.9060701@redhat.com>
Date: Fri, 17 Apr 2015 16:37:32 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <A8EE2778-45FE-4EC6-AB41-278D8745D068@dilger.ca>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com> <55310957.3070101@gmail.com> <55311DE2.9000901@redhat.com> <20150417154351.GA26736@quack.suse.cz> <55312FEA.3030905@redhat.com> <20150417162247.GB27500@quack.suse.cz> <553144EB.9060701@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Spray <john.spray@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Austin S Hemmelgarn <ahferroin7@gmail.com>, Beata Michalska <b.michalska@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, =?windows-1252?Q?Luk=E1=9A_Czerner?= <lczerner@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ext4 <linux-ext4@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Apr 17, 2015, at 11:37 AM, John Spray <john.spray@redhat.com> wrote:
> On 17/04/2015 17:22, Jan Kara wrote:
>> On Fri 17-04-15 17:08:10, John Spray wrote:
>>> On 17/04/2015 16:43, Jan Kara wrote:
>>> In that case I'm confused -- why would ENOSPC be an appropriate use
>>> of this interface if the mount being entirely blocked would be
>>> inappropriate?  Isn't being unable to service any I/O a more
>>> fundamental and severe thing than being up and healthy but full?
>>>=20
>>> Were you intending the interface to be exclusively for data
>>> integrity issues like checksum failures, rather than more general
>>> events about a mount that userspace would probably like to know
>>> about?
>>   Well, I'm not saying we cannot have those events for fs =
availability /
>> inavailability. I'm just saying I'd like to see some use for that =
first.
>> I don't want events to be added just because it's possible...
>>=20
>> For ENOSPC we have thin provisioned storage and the userspace deamon
>> shuffling real storage underneath. So there I know the usecase.
>>=20
>=20
> Ah, OK.  So I can think of a couple of use cases:
> * a cluster scheduling service (think MPI jobs or docker containers) =
might check for events like this.  If it can see the cluster filesystem =
is unavailable, then it can avoid scheduling the job, so that the =
(multi-node) application does not get hung on one node with a bad mount. =
 If it sees a mount go bad (unavailable, or client evicted) partway =
through a job, then it can kill -9 the process that was relying on the =
bad mount, and go run it somewhere else.
> * Boring but practical case: a nagios health check for checking if =
mounts are OK.

John,
thanks for chiming in, as I was just about to write the same.  Some =
users
were just asking yesterday at the Lustre User Group meeting about adding
an interface to notify job schedulers for your #1 point, and I'd much
rather use a generic interface than inventing our own for Lustre.

Cheers, Andreas

> We don't have to invent these event types now of course, but something =
to bear in mind.  Hopefully if/when any of the distributed filesystems =
(Lustre/Ceph/etc) choose to implement this, we can look at making the =
event types common at that time though.
>=20
> BTW in any case an interface for filesystem events to userspace will =
be a useful addition, thank you!
>=20
> Cheers,
> John


Cheers, Andreas





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
