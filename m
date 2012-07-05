Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id F36346B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 09:57:03 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SmmYB-00020M-GK
	for linux-mm@kvack.org; Thu, 05 Jul 2012 15:56:56 +0200
Received: from 117.57.98.8 ([117.57.98.8])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 15:56:55 +0200
Received: from xiyou.wangcong by 117.57.98.8 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 15:56:55 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Bad use of highmem with buffer_migrate_page?
Date: Thu, 5 Jul 2012 13:56:43 +0000 (UTC)
Message-ID: <jt46eq$lq0$4@dough.gmane.org>
References: <4FAC200D.2080306@codeaurora.org>
 <02fc01cd2f50$5d77e4c0$1867ae40$%szyprowski@samsung.com>
 <4FAD89DC.2090307@codeaurora.org>
 <CAH+eYFBhO9P7V7Nf+yi+vFPveBks7SFKRHfkz3JOQMBKqnkkUQ@mail.gmail.com>
 <015f01cd5a95$c1525dc0$43f71940$%szyprowski@samsung.com>
 <20120705104520.GA6773@latitude>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On Thu, 05 Jul 2012 at 10:45 GMT, Rabin Vincent <rabin@rab.in> wrote:
> 8<----
> From 8a94126eb3aa2824866405fb78bb0b8316f8fd00 Mon Sep 17 00:00:00 2001
> From: Rabin Vincent <rabin@rab.in>
> Date: Thu, 5 Jul 2012 15:52:23 +0530
> Subject: [PATCH] mm: cma: don't replace lowmem pages with highmem
>
> The filesystem layer expects pages in the block device's mapping to not
> be in highmem (the mapping's gfp mask is set in bdget()), but CMA can
> currently replace lowmem pages with highmem pages, leading to crashes in
> filesystem code such as the one below:
>
...
> Fix this by replacing only highmem pages with highmem.
>

Looks good to me too,

    Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
