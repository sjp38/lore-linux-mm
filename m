Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC036B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:25:05 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id z143so203999340ywz.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 09:25:05 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id t59si4321306ybi.107.2017.01.23.09.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 09:25:04 -0800 (PST)
Date: Mon, 23 Jan 2017 12:25:00 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170123172500.itzbe7qgzcs6kgh2@thunk.org>
References: <20170113110959.GA4981@noname.redhat.com>
 <20170113142154.iycjjhjujqt5u2ab@thunk.org>
 <20170113160022.GC4981@noname.redhat.com>
 <87mveufvbu.fsf@notabene.neil.brown.name>
 <1484568855.2719.3.camel@poochiereds.net>
 <87o9yyemud.fsf@notabene.neil.brown.name>
 <1485127917.5321.1.camel@poochiereds.net>
 <20170123002158.xe7r7us2buc37ybq@thunk.org>
 <20170123100941.GA5745@noname.redhat.com>
 <1485173400.2786.5.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485173400.2786.5.camel@poochiereds.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Kevin Wolf <kwolf@redhat.com>, NeilBrown <neilb@suse.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>

On Mon, Jan 23, 2017 at 07:10:00AM -0500, Jeff Layton wrote:
> > > Well, except for QEMU/KVM, Kevin has already confirmed that using
> > > Direct I/O is a completely viable solution.  (And I'll add it solves a
> > > bunch of other problems, including page cache efficiency....)
> 
> Sure, O_DIRECT does make this simpler (though it's not always the most
> efficient way to do I/O). I'm more interested in whether we can improve
> the error handling with buffered I/O.

I just want to make sure we're designing a solution that will actually
be _used_, because it is a good fit for at least one real-world use
case.

Is QEMU/KVM using volumes that are stored over NFS really used in the
real world?  Especially one where you want a huge amount of
reliability and recovery after some kind network failure?  If we are
talking about customers who are going to suspend the VM and restart it
on another server, that presumes a fairly large installation size and
enough servers that would they *really* want to use a single point of
failure such as an NFS filer?  Even if it was a proprietary
purpose-built NFS filer?  Why wouldn't they be using RADOS and Ceph
instead, for example?

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
