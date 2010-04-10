Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1B43E6B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 17:21:34 -0400 (EDT)
Message-ID: <0d6501cad8f3$d816b5e0$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <00bb01cad70d$a814c2c0$0400a8c0@dcccs> <alpine.DEB.2.01.1004091435170.29272@bogon.housecafe.de> <099001cad836$39dc6860$0400a8c0@dcccs> <20100410080631.GA9772@hack>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a lookplease!...)
Date: Sat, 10 Apr 2010 23:21:53 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?iso-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: lists@nerdbynature.de, david@fromorbit.com, axboe@kernel.dk, "\"LKML\"" <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi,


----- Original Message ----- 
From: "Americo Wang" <xiyou.wangcong@gmail.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: "Christian Kujau" <lists@nerdbynature.de>; <david@fromorbit.com>; 
<axboe@kernel.dk>; "LKML" <linux-kernel@vger.kernel.org>; <xfs@oss.sgi.com>; 
<linux-mm@kvack.org>; <xiyou.wangcong@gmail.com>; 
<kamezawa.hiroyu@jp.fujitsu.com>
Sent: Saturday, April 10, 2010 10:06 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a 
lookplease!...)


> On Sat, Apr 10, 2010 at 12:44:28AM +0200, Janos Haar wrote:
>> Hello,
>>
>
> Hi,
>
>> I am just started to test the stable-queue patch series on 2.6.32.10.
>> Now running, we will see...
>> The 2.6.33.2 made 4 crashes in the last 3 days. :-(
>> This was more worse than the original 2.6.32.10.
>>
>> (I am very interested, anyway, this is the last shot of this server.
>> The owner giving me an ultimate.
>> If the server crashes again in the next week, i need to replace the
>> entire HW, the OS, and the services as well...)
>>
>
> I would recommend you to use a distribution-released kernel,
> rather than a stable kernel from kernel.org, because usually
> the distribution maintains a longer supported kernel than
> kernel.org.
>
> Just a little suggestion. Hope it helps for you to choose Linux. ;)

Personally, i am really like Linux, and use it since 1990. :-)
I have set up about 30 servers or more...
Usually i can't use the distro-release kernels, because these usually too 
old.
Additionally i can find bugs on any software and in any kernel version.... 
B-)
This is not the first time when i report bugs from the kernel, maybe the 4th 
or 5th time...
(I was who helped to solve the original NBD deadlock problem as well about 
2005.)

Anyway, thanks for your suggestion. ;-)

Cheers,
Janos

>
> Thanks.
>
> -- 
> Live like a child, think like the god.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
