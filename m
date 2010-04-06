Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 87C426B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:22:14 -0400 (EDT)
Date: Tue, 6 Apr 2010 09:22:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100406012206.GD5295@localhost>
References: <20100331145602.03A7.A69D9226@jp.fujitsu.com> <20100401151639.a030fb10.akpm@linux-foundation.org> <20100402180812.646D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402180812.646D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> ===================================================================
> >From 52358cbccdfe94e0381974cd6e937bcc6b1c608b Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Fri, 2 Apr 2010 17:13:48 +0900
> Subject: [PATCH] Revert "vmscan: get_scan_ratio() cleanup"
> 
> Shaohua Li reported his tmpfs streaming I/O test can lead to make oom.
> The test uses a 6G tmpfs in a system with 3G memory. In the tmpfs,
> there are 6 copies of kernel source and the test does kbuild for each
> copy. His investigation shows the test has a lot of rotated anon
> pages and quite few file pages, so get_scan_ratio calculates percent[0]
> (i.e. scanning percent for anon)  to be zero. Actually the percent[0]
> shoule be a big value, but our calculation round it to zero.

  should      small :)

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
