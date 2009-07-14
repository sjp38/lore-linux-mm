Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C5E286B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 23:42:24 -0400 (EDT)
Received: from coyote.coyote.den ([72.65.71.44]) by vms173011.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KMR002LX7LE6020@vms173011.mailsrvcs.net> for
 linux-mm@kvack.org; Mon, 13 Jul 2009 23:10:26 -0500 (CDT)
From: Gene Heskett <gene.heskett@verizon.net>
Subject: Re: OOM killer in 2.6.31-rc2
Date: Tue, 14 Jul 2009 00:10:25 -0400
References: <200907061056.00229.gene.heskett@verizon.net>
 <200907110819.30337.gene.heskett@verizon.net> <20090712051441.GA7903@localhost>
In-reply-to: <20090712051441.GA7903@localhost>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7bit
Content-disposition: inline
Message-id: <200907140010.25643.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 12 July 2009, Wu Fengguang wrote:

>> This 18 hours of uptime is a record by at least 3x what I've ever gotten
>> from this bios before.  On the one hand I am pleased, on the other the
>> lack of results so far has to be somewhat disappointing.
>
>Don't be in a hurry. Just enjoy the current good state until OOM revisits :)

Its been about 3d 10h of uptime now, and its been boringly stable.  Darn it.

Memory usage ack to htop has about doubled (to 828 megs from 385 or so 
originally), and its 24MB into swap, so I'd assume there is a small leak 
somewhere.  At this rate it will take weeks to trigger this again.

I've now built 2.6.31-rc3 with pretty much the same options re: memory, and 
will probably reboot to it in the morning as its approaching the witching hour 
here.  Any objections?

>Thanks,
>Fengguang

-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
The NRA is offering FREE Associate memberships to anyone who wants them.
<https://www.nrahq.org/nrabonus/accept-membership.asp>

Q:	Why haven't you graduated yet?
A:	Well, Dad, I could have finished years ago, but I wanted
	my dissertation to rhyme.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
