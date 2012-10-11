Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 277B76B005A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:14:15 -0400 (EDT)
Date: Thu, 11 Oct 2012 15:14:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kswapd0: wxcessive CPU usage
Message-Id: <20121011151413.3ab58542.akpm@linux-foundation.org>
In-Reply-To: <507688CC.9000104@suse.cz>
References: <507688CC.9000104@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>

On Thu, 11 Oct 2012 10:52:28 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> with 3.6.0-next-20121008, kswapd0 is spinning my CPU at 100% for 1
> minute or so. If I try to suspend to RAM, this trace appears:
> kswapd0         R  running task        0   577      2 0x00000000
>  0000000000000000 00000000000000c0 cccccccccccccccd ffff8801c4146800
>  ffff8801c4b15c88 ffffffff8116ee05 0000000000003e32 ffff8801c3a79000
>  ffff8801c4b15ca8 ffffffff8116fdf8 ffff8801c480f398 ffff8801c3a79000
> Call Trace:
>  [<ffffffff8116ee05>] ? put_super+0x25/0x40
>  [<ffffffff8116fdd4>] ? grab_super_passive+0x24/0xa0
>  [<ffffffff8116ff99>] ? prune_super+0x149/0x1b0
>  [<ffffffff81131531>] ? shrink_slab+0xa1/0x2d0
>  [<ffffffff8113452d>] ? kswapd+0x66d/0xb60
>  [<ffffffff81133ec0>] ? try_to_free_pages+0x180/0x180
>  [<ffffffff810a2770>] ? kthread+0xc0/0xd0
>  [<ffffffff810a26b0>] ? kthread_create_on_node+0x130/0x130
>  [<ffffffff816a6c9c>] ? ret_from_fork+0x7c/0x90
>  [<ffffffff810a26b0>] ? kthread_create_on_node+0x130/0x130

Could you please do a sysrq-T a few times while it's spinning, to
confirm that this trace is consistently the culprit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
