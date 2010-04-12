Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D04C76B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:34:39 -0400 (EDT)
Received: by iwn14 with SMTP id 14so3863808iwn.22
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 20:34:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
Date: Mon, 12 Apr 2010 12:34:38 +0900
Message-ID: <z2u28c262361004112034sc52d79f9ocbcc5a7a3a7279d5@mail.gmail.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 8:49 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Since alloc_pages_exact_node() is not for allocate page from
> exact node but just for removing check of node's valid,
> rename it to alloc_pages_from_valid_node(). Else will make
> people misunderstanding.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I like this naming.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
