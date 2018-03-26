Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D250C6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:36:19 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m6-v6so13829950pln.8
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:36:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z7sor5470058pfa.31.2018.03.26.15.36.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 15:36:18 -0700 (PDT)
Date: Mon, 26 Mar 2018 15:36:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
In-Reply-To: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
Message-ID: <alpine.DEB.2.20.1803261535460.93873@chino.kir.corp.google.com>
References: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 26 Mar 2018, Joe Perches wrote:

> mm/*.c files use symbolic and octal styles for permissions.
> 
> Using octal and not symbolic permissions is preferred by many as more
> readable.
> 
> https://lkml.org/lkml/2016/8/2/1945
> 
> Prefer the direct use of octal for permissions.
> 
> Done using
> $ scripts/checkpatch.pl -f --types=SYMBOLIC_PERMS --fix-inplace mm/*.c
> and some typing.
> 
> Before:	 $ git grep -P -w "0[0-7]{3,3}" mm | wc -l
> 44
> After:	 $ git grep -P -w "0[0-7]{3,3}" mm | wc -l
> 86
> 
> Miscellanea:
> 
> o Whitespace neatening around these conversions.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: David Rientjes <rientjes@google.com>

although extending some of these lines to be >80 characters also improves 
the readability imo.
