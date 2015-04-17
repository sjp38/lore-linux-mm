Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0400E900018
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:46:54 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so123131351pdb.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:46:53 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id fe2si15987501pab.161.2015.04.17.02.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 02:46:53 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMY00BU53CS9K00@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Apr 2015 10:50:52 +0100 (BST)
Message-id: <5530D686.9080807@samsung.com>
Date: Fri, 17 Apr 2015 11:46:46 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <55302FFB.4010108@gmx.de>
In-reply-to: <55302FFB.4010108@gmx.de>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Jan Kara <jack@suse.cz>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org


Hi,

On 04/16/2015 11:56 PM, Heinrich Schuchardt wrote:
> On 15.04.2015 09:15, Beata Michalska wrote:
>> Introduce configurable generic interface for file
>> system-wide event notifications to provide file
>> systems with a common way of reporting any potential
>> issues as they emerge.
>>
>> The notifications are to be issued through generic
>> netlink interface, by a dedicated, for file system
>> events, multicast group. The file systems might as
>> well use this group to send their own custom messages.
>>
>> The events have been split into four base categories:
>> information, warnings, errors and threshold notifications,
>> with some very basic event types like running out of space
>> or file system being remounted as read-only.
>>
>> Threshold notifications have been included to allow
>> triggering an event whenever the amount of free space
>> drops below a certain level - or levels to be more precise
>> as two of them are being supported: the lower and the upper
>> range. The notifications work both ways: once the threshold
>> level has been reached, an event shall be generated whenever
>> the number of available blocks goes up again re-activating
>> the threshold.
>>
>> The interface has been exposed through a vfs. Once mounted,
>> it serves as an entry point for the set-up where one can
>> register for particular file system events.
> 
> Having a framework for notification for file systems is a great idea.
> Your solution covers an important part of the possible application scope.
> 
> Before moving forward I suggest we should analyze if this scope should
> be enlarged.
> 
> Many filesystems are remote (e.g. CIFS/Samba) or distributed over many
> network nodes (e.g. Lustre). How should file system notification work here?
> 
> How will fuse file systems be served?
> 
> The current point of reference is a single mount point.
> Every time I insert an USB stick several file system may be automounted.
> I would like to receive events for these automounted file systems.
> 
> A similar case arises when starting new virtual machines. How will I
> receive events on the host system for the file systems of the virtual
> machines?

> In your implementation events are received via Netlink.
> Using Netlink for marking mounts for notification would create a much
> more homogenous interface. So why should we use a virtual file system here?
> 
> Best regards
> 
> Heinrich Schuchardt
> 
> 

I'd be more than happy to extend the scope of suggested changes.
I hope I'll be able to collect more comments - in this way there 
is a chance we might get here smth that is really useful, for everyone.

I've tried to make the interface rather flexible, so that new cases
can be easily added - so the notification whenever a file system
is being mounted is definitely doable.

The vfs here merely serves the purpose to configure which type of events
and for which filesystems are to be issued. Having this done through
netlink is also an option, though it needs some more thoughts. The way
notifications are being sent might be extended: so there could be more
than one option for this. We might also want to consider if we want to
have this widely available - everything for everyone. (?)

As for the rest, I must admit I'm not really an fs person, so I assume
there will be more comments and questions like yours. This is also why
any comments/hints/remarks/doubts/issues etc would me more than just
welcomed. I'll try to answer them all, though this will require some
time on my side, thus apologies if I have some delays.


I'll get beck to this asap.

BR
Beata




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
