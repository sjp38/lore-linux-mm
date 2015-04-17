Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 63E016B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 12:25:45 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so130153778pab.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:25:45 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id pc5si17371354pac.85.2015.04.17.09.25.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 09:25:44 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMY00DTNLW0J650@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Apr 2015 17:31:12 +0100 (BST)
Message-id: <55313401.5080008@samsung.com>
Date: Fri, 17 Apr 2015 18:25:37 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com>
 <55310957.3070101@gmail.com> <55311DE2.9000901@redhat.com>
 <20150417154351.GA26736@quack.suse.cz> <55312FEA.3030905@redhat.com>
In-reply-to: <55312FEA.3030905@redhat.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Spray <john.spray@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Austin S Hemmelgarn <ahferroin7@gmail.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On 04/17/2015 06:08 PM, John Spray wrote:
> 
> On 17/04/2015 16:43, Jan Kara wrote:
>> On Fri 17-04-15 15:51:14, John Spray wrote:
>>> On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
>>>
>>>> For some filesystems, it may make sense to differentiate between a
>>>> generic warning and an error.  For BTRFS and ZFS for example, if
>>>> there is a csum error on a block, this will get automatically
>>>> corrected in many configurations, and won't require anything like
>>>> fsck to be run, but monitoring applications will still probably
>>>> want to be notified.
>>> Another key differentiation IMHO is between transient errors (like
>>> server is unavailable in a distributed filesystem) that will block
>>> the filesystem but might clear on their own, vs. permanent errors
>>> like unreadable drives that definitely will not clear until the
>>> administrator takes some action.  It's usually a reasonable
>>> approximation to call transient issues warnings, and permanent
>>> issues errors.
>>    So you can have events like FS_UNAVAILABLE and FS_AVAILABLE but what use
>> would this have? I wouldn't like the interface to be dumping ground for
>> random crap - we have dmesg for that :).
> In that case I'm confused -- why would ENOSPC be an appropriate use of this interface if the mount being entirely blocked would be inappropriate?  Isn't being unable to service any I/O a more fundamental and severe thing than being up and healthy but full?
> 
> Were you intending the interface to be exclusively for data integrity issues like checksum failures, rather than more general events about a mount that userspace would probably like to know about?
> 
> John
> 

I think we should support both and leave the decision on what
is to be reported or not to particular file systems keeping it
to a reasonable extent, of course. The interface should hand it over
to user space - acting as a go-between. I would though avoid
any filesystem specific events (when it comes to specifying those),
keeping it as generic as possible.


BR
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
