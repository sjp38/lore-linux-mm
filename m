Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA23142
	for <linux-mm@kvack.org>; Wed, 6 Nov 2002 11:30:20 -0800 (PST)
Message-ID: <3DC96DCC.A7094AEC@digeo.com>
Date: Wed, 06 Nov 2002 11:30:20 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.46: sleeping function called from illegal context at
 mm/slab.c:1305
References: <Pine.LNX.4.44.0211061308510.14931-100000@ennui.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kent Yoder <key@austin.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Kent Yoder wrote:
> 
>   Seen on boot from 2.5.46-bk pulled earlier today.  This is a UP pentium 3
> w/ 256 MB RAM. For some reason this sounds like a duplicate but I didn't see
> anything...
> 
> Kent
> 
> slab: reap timer started for cpu 0
> Starting kswapd
> aio_setup: sizeof(struct page) = 40
> [cfea2020] eventpoll: driver installed.
> Debug: sleeping function called from illegal context at mm/slab.c:1305
> Call Trace:
>  [<c0143367>] kmem_flagcheck+0x67/0x70
>  [<c0143d47>] kmalloc+0x67/0xc0
>  [<c01461bf>] set_shrinker+0x1f/0xa0
>  [<c0188a10>] mb_cache_create+0x1f0/0x2d0
>  [<c0188640>] mb_cache_shrink_fn+0x0/0x1e0
>  [<c0160299>] do_kern_mount+0xa9/0xe0
>  [<c01050c3>] init+0x83/0x1b0
>  [<c0105040>] init+0x0/0x1b0
>  [<c010730d>] kernel_thread_helper+0x5/0x18

Yup, thanks.  Andreas has prepared a patch which fixes this up.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
