Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7466B6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:58:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t138so5645596wmt.7
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:58:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 12si1844001wme.229.2017.08.29.13.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:58:09 -0700 (PDT)
Date: Tue, 29 Aug 2017 13:58:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][v2] mm: use sc->priority for slab shrink targets
Message-Id: <20170829135806.6599f585211058e0842fab85@linux-foundation.org>
In-Reply-To: <20170829204026.GA7605@cmpxchg.org>
References: <1503589176-1823-1-git-send-email-jbacik@fb.com>
	<20170829204026.GA7605@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: josef@toxicpanda.com, minchan@kernel.org, linux-mm@kvack.org, riel@redhat.com, david@fromorbit.com, kernel-team@fb.com, aryabinin@virtuozzo.com, Josef Bacik <jbacik@fb.com>

On Tue, 29 Aug 2017 16:40:26 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> This looks good to me, thanks for persisting Josef.
> 
> There is a small cleanup possible on top of this, as the slab shrinker
> was the only thing that used that lru_pages accumulation when the scan
> targets are calculated.

I'm inclined to park this until 4.14-rc1, unless we see a pressing need
to get it into 4.13?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
