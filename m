Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 64B486B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 13:56:22 -0400 (EDT)
Date: Tue, 14 Jul 2009 11:47:51 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Re: [PATCH 0/4] OOM analysis helper patch series v3
In-Reply-To: <20090713144924.6257.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0907141141100.1598@mail.selltech.ca>
References: <20090713144924.6257.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009, KOSAKI Motohiro wrote:

> ChangeLog
>  Since v2
>    - Dropped "[4/5] add isolate pages vmstat" temporary because it become
>      slightly big. Then, I plan to submit it as another patchset.
>    - Rewrote many patch description (Thanks! Christoph)
>  Since v1
>    - Dropped "[5/5] add NR_ANON_PAGES to OOM log" patch
>    - Instead, introduce "[5/5] add shmem vmstat" patch
>    - Fixed unit bug (Thanks Minchan)
>    - Separated isolated vmstat to two field (Thanks Minchan and Wu)
>    - Fixed isolated page and lumpy reclaim issue (Thanks Minchan)
>    - Rewrote some patch description (Thanks Christoph)
> 
> This patch series are tested on 2.6.31-rc2 + mm-show_free_areas-display-slab-pages-in-two-separate-fields.patch

For your information, I tested the patches on 2.6.31-rc3 + 
mm-show_free_areas-display-slab-pages-in-two-separate-fields.patch. It is 
fine.

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
