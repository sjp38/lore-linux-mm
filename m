Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E4C3B5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:21:02 -0400 (EDT)
Date: Tue, 2 Jun 2009 11:14:14 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-ID: <20090602091413.GB15756@elf.ucw.cz>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com> <20090601123503.2337a79b.akpm@linux-foundation.org> <4A242F94.9010704@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A242F94.9010704@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, linux-mm@kvack.org, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon 2009-06-01 22:44:20, Avi Kivity wrote:
> Andrew Morton wrote:
>>> We really should have a machine readable channel for this sort of  
>>> information, so it can be plumbed to a userspace notification bubble 
>>> the user can ignore.
>>>     
>>
>> That could just be printk().  It's a question of a) how to tell
>> userspace which bits to pay attention to and maybe b) adding some
>> more structure to the text.
>>
>> Perhaps careful use of faciliy levels would suffice for a), but I
>> expect that some new tagging scheme would be more practical.
>>   
>
> I thought dmesg was an unreliable channel which can overflow.  It's also  
> prone to attacks by spell checkers.

Well, I believe that any used-enough channecl will eventually
overflow. So dmesg still looks like the best we can do.

> I prefer reliable binary interfaces to shell explorable text interfaces  
> as I think any feature worth having is much more useful controlled by an  
> application rather than a bored sysadmin.

You are free to parse syslog. In fact, I guess some tags could be
added for messages where userland reaction is expected...
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
