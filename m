Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 51A586B022F
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 18:44:21 -0400 (EDT)
Message-ID: <099001cad836$39dc6860$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <00bb01cad70d$a814c2c0$0400a8c0@dcccs> <alpine.DEB.2.01.1004091435170.29272@bogon.housecafe.de>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Sat, 10 Apr 2010 00:44:28 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Kujau <lists@nerdbynature.de>
Cc: david@fromorbit.com, axboe@kernel.dk, "\"LKML\"" <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org, xiyou.wangcong@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hello,

I am just started to test the stable-queue patch series on 2.6.32.10.
Now running, we will see...
The 2.6.33.2 made 4 crashes in the last 3 days. :-(
This was more worse than the original 2.6.32.10.

(I am very interested, anyway, this is the last shot of this server.
The owner giving me an ultimate.
If the server crashes again in the next week, i need to replace the entire 
HW, the OS, and the services as well...)

Thanks a lot for help.

Best Regards,
Janos Haar

----- Original Message ----- 
From: "Christian Kujau" <lists@nerdbynature.de>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: "Dave Chinner" <david@fromorbit.com>; <axboe@kernel.dk>; "LKML" 
<linux-kernel@vger.kernel.org>; <xfs@oss.sgi.com>; <linux-mm@kvack.org>; 
<xiyou.wangcong@gmail.com>; <kamezawa.hiroyu@jp.fujitsu.com>
Sent: Friday, April 09, 2010 11:37 PM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Thu, 8 Apr 2010 at 13:21, Janos Haar wrote:
>> > Yeah, these still a fix that needs to be back ported to .33
>> > to solve this problem. It's in the series for 2.6.32.x, so maybe
>> > pulling the 2.6.32-stable-queue tree in the meantime is your best
>> > bet.
>>
>> Ok, thank you.
>> But where can i find this tree?
>
>
> Perhaps Dave meant the stable-queue?
>
> http://git.kernel.org/?p=linux/kernel/git/stable/stable-queue.git
>
> Then again, 2.6.34-rc3 needs testing too! :-)
>
> Christian.
> -- 
> BOFH excuse #98:
>
> The vendor put the bug there. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
