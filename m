Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id E15426B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 12:08:18 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so26458384qcy.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:08:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 186si12039148qhw.24.2015.04.17.09.08.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 09:08:17 -0700 (PDT)
Message-ID: <55312FEA.3030905@redhat.com>
Date: Fri, 17 Apr 2015 17:08:10 +0100
From: John Spray <john.spray@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com> <55310957.3070101@gmail.com> <55311DE2.9000901@redhat.com> <20150417154351.GA26736@quack.suse.cz>
In-Reply-To: <20150417154351.GA26736@quack.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org


On 17/04/2015 16:43, Jan Kara wrote:
> On Fri 17-04-15 15:51:14, John Spray wrote:
>> On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
>>
>>> For some filesystems, it may make sense to differentiate between a
>>> generic warning and an error.  For BTRFS and ZFS for example, if
>>> there is a csum error on a block, this will get automatically
>>> corrected in many configurations, and won't require anything like
>>> fsck to be run, but monitoring applications will still probably
>>> want to be notified.
>> Another key differentiation IMHO is between transient errors (like
>> server is unavailable in a distributed filesystem) that will block
>> the filesystem but might clear on their own, vs. permanent errors
>> like unreadable drives that definitely will not clear until the
>> administrator takes some action.  It's usually a reasonable
>> approximation to call transient issues warnings, and permanent
>> issues errors.
>    So you can have events like FS_UNAVAILABLE and FS_AVAILABLE but what use
> would this have? I wouldn't like the interface to be dumping ground for
> random crap - we have dmesg for that :).
In that case I'm confused -- why would ENOSPC be an appropriate use of 
this interface if the mount being entirely blocked would be 
inappropriate?  Isn't being unable to service any I/O a more fundamental 
and severe thing than being up and healthy but full?

Were you intending the interface to be exclusively for data integrity 
issues like checksum failures, rather than more general events about a 
mount that userspace would probably like to know about?

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
