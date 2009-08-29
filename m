Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 419696B004D
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:54:49 -0400 (EDT)
Received: by ywh16 with SMTP id 16so2162763ywh.19
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 21:54:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
References: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
Date: Sat, 29 Aug 2009 13:54:56 +0900
Message-ID: <2f11576a0908282154l6351d181s98cdae8829e80d6c@mail.gmail.com>
Subject: Re: [PATCH] mm/memory-failure: remove CONFIG_UNEVICTABLE_LRU config
	option
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2009/8/29 Vincent Li <macli@brc.ubc.ca>:
> Commit 683776596 (remove CONFIG_UNEVICTABLE_LRU config option) removed th=
is config option.
> Removed it from mm/memory-failure too.
>
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> ---
> =A0mm/memory-failure.c | =A0 =A02 --
> =A01 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f78d9fc..2bc4c50 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -587,10 +587,8 @@ static struct page_state {
> =A0 =A0 =A0 =A0{ sc|dirty, =A0 =A0 sc|dirty, =A0 =A0 =A0 "swapcache", =A0=
 =A0me_swapcache_dirty },
> =A0 =A0 =A0 =A0{ sc|dirty, =A0 =A0 sc, =A0 =A0 =A0 =A0 =A0 =A0 "swapcache=
", =A0 =A0me_swapcache_clean },
>
> -#ifdef CONFIG_UNEVICTABLE_LRU
> =A0 =A0 =A0 =A0{ unevict|dirty, unevict|dirty, "unevictable LRU", me_page=
cache_dirty},
> =A0 =A0 =A0 =A0{ unevict, =A0 =A0 =A0unevict, =A0 =A0 =A0 =A0"unevictable=
 LRU", me_pagecache_clean},
> -#endif

Looks good to me.
     Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
