Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28BCD6B01F0
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 19:06:14 -0400 (EDT)
Message-ID: <2e1a01cad513$b242fd30$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com> <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com> <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Tue, 6 Apr 2010 00:59:48 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>


----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Tuesday, April 06, 2010 12:45 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Mon, Apr 05, 2010 at 08:17:27PM +0200, Janos Haar wrote:
>> Dave,
>>
>> Thank you for your answer.
>> Like i sad before, this is a productive server with important service.
>> Can you please send the fix for me as soon as it is done even for
>> testing it....
>> Or point me to the right direction to get it?
>
> It's in 2.6.33 if you want to upgrade the kernel, or you if don't
> want to wait for the next 2.6.32.x kernel, you can apply this series
> of 19 patches yourself:

Generally, for this system, i am much more prefer the extra-stable series, 
but in this case i will try out the 2.6.33 because these 2 versions is close 
to each other, and i don't want to add 19 patches manually. :-)
I will try it, and i will reply about the result in this week.

Thanks for You and for all the people, who works on XFS and Linux. :-)

Best Regards,
Janos Haar


>
> http://oss.sgi.com/archives/xfs/2010-03/msg00125.html
>
> Cheers,
>
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
