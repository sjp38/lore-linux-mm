Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 827806B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 04:02:49 -0400 (EDT)
Received: by vws15 with SMTP id 15so549301vws.14
        for <linux-mm@kvack.org>; Sat, 10 Apr 2010 01:02:47 -0700 (PDT)
Date: Sat, 10 Apr 2010 16:06:31 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look
	please!...)
Message-ID: <20100410080631.GA9772@hack>
References: <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <00bb01cad70d$a814c2c0$0400a8c0@dcccs> <alpine.DEB.2.01.1004091435170.29272@bogon.housecafe.de> <099001cad836$39dc6860$0400a8c0@dcccs>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <099001cad836$39dc6860$0400a8c0@dcccs>
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: Christian Kujau <lists@nerdbynature.de>, david@fromorbit.com, axboe@kernel.dk, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, linux-mm@kvack.org, xiyou.wangcong@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 12:44:28AM +0200, Janos Haar wrote:
> Hello,
>

Hi,

> I am just started to test the stable-queue patch series on 2.6.32.10.
> Now running, we will see...
> The 2.6.33.2 made 4 crashes in the last 3 days. :-(
> This was more worse than the original 2.6.32.10.
>
> (I am very interested, anyway, this is the last shot of this server.
> The owner giving me an ultimate.
> If the server crashes again in the next week, i need to replace the 
> entire HW, the OS, and the services as well...)
>

I would recommend you to use a distribution-released kernel,
rather than a stable kernel from kernel.org, because usually
the distribution maintains a longer supported kernel than
kernel.org.

Just a little suggestion. Hope it helps for you to choose Linux. ;)

Thanks.

-- 
Live like a child, think like the god.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
