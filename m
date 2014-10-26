Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 665576B006C
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 14:20:54 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id f15so3651615lbj.13
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 11:20:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qy3si16624318lbb.3.2014.10.26.11.20.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Oct 2014 11:20:52 -0700 (PDT)
Date: Sun, 26 Oct 2014 14:20:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Kswapd 100% CPU since 3.8 on Sandybridge
Message-ID: <20141026182043.GA28435@phnom.home.cmpxchg.org>
References: <CABe+QzA=0YVpQ8rN+3X-cbH6JP1nWTvp2spb93P9PqJhmjBROA@mail.gmail.com>
 <CABe+QzA-E40bFFXYJBc663Kx0KrE3xy2uZq5xOH2XL6mFPA6+w@mail.gmail.com>
 <CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
 <20141006093740.GA19574@suse.de>
 <20141026160057.GA5234@puck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141026160057.GA5234@puck>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sarah <sarah@thesharps.us>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

Hi Sarah,

On Sun, Oct 26, 2014 at 09:05:34AM -0700, sarah wrote:
> One hypothesis I had was the system was hanging because kswapd was hammering on
> the disk, and it was really low on disk space (< 1 GB).  But I've moved about 20
> GB of roadtrip photos to my USB 3.0 drive, and I can still replicate the slow
> system behavior.  I was also poking around /etc/fstab, and I realized that I had
> actually disabled my swap partition around the 3.12 kernel time frame to see if
> that helped the issue.  That lead me to wonder why kswapd was running at all?

Kswapd isn't just there to swap, it reclaims pages in the background
when memory is filling up in order to keep allocation latencies low.
That includes trimming the page cache, shrinking slabs, even writing
back dirty pages.  So "kswapd" is a bit of a misnomer, and it's
expected to run even when you don't have any swap space configured.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
