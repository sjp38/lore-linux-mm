Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id C673F6B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 05:06:56 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so595344dak.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 02:06:56 -0800 (PST)
Date: Mon, 19 Nov 2012 02:06:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 1/2 v2]swap: add a simple buddy allocator
In-Reply-To: <20121119075943.GA17405@kernel.org>
Message-ID: <alpine.LNX.2.00.1211190151320.20469@eggly.anvils>
References: <20121119075943.GA17405@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, riel@redhat.com

On Mon, 19 Nov 2012, Shaohua Li wrote:
> 
> Changes from V1 to V2:
> 1. free cluster is added to a list, which makes searching cluster more efficient
> 2. only enable the buddy allocator for SSD.

Oh.  My fault, not yours at all, but I wish I'd known this was coming.
I spent today testing and fixing (a couple of hangs in discard 2/2) V1,
was about to send you a patch, but looks like none of it relevant to V2.

It's nice work you've done, I thoroughly approve of V1 (very minor mods),
but it'll take me a few more days to get around to looking at V2, sorry.

Though, it may be my ignorance, I entirely fail to see what this has to
do with a buddy allocator: you've speeded up scan_swap_map()'s search
for a cluster by adding an additional cluster map, then extended that
neatly for a much better discard implementation.  Good work yes, but
a buddy allocator??

Thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
