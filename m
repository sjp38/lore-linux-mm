Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3DA6B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 02:52:57 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so2900217pab.12
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 23:52:57 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id kj6si69416pbc.109.2014.08.05.23.52.53
        for <linux-mm@kvack.org>;
        Tue, 05 Aug 2014 23:52:54 -0700 (PDT)
Date: Wed, 6 Aug 2014 15:52:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/3] zram: limit memory size for zram
Message-ID: <20140806065253.GC3796@bbox>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <1407225723-23754-4-git-send-email-minchan@kernel.org>
 <20140805094859.GE27993@bbox>
 <20140805131615.GA961@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140805131615.GA961@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

On Tue, Aug 05, 2014 at 10:16:15PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (08/05/14 18:48), Minchan Kim wrote:
> > Another idea: we could define void zs_limit_mem(unsinged long nr_pages)
> > in zsmalloc and put the limit in zs_pool via new API from zram so that
> > zs_malloc could be failed as soon as it exceeds the limit.
> > 
> > In the end, zram doesn't need to call zs_get_total_size_bytes on every
> > write. It's more clean and right layer, IMHO.
> 
> yes, I think this one is better.
> 
> 	-ss
