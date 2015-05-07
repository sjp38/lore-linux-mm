Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D0F646B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 18:52:32 -0400 (EDT)
Received: by wiun10 with SMTP id n10so8320891wiu.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 15:52:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj6si9782113wib.101.2015.05.07.15.52.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 May 2015 15:52:31 -0700 (PDT)
Date: Thu, 7 May 2015 23:52:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150507225226.GM2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
 <20150507072518.GL2462@suse.de>
 <20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 07, 2015 at 03:09:32PM -0700, Andrew Morton wrote:
> On Thu, 7 May 2015 08:25:18 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Waiman Long reported that 24TB machines hit OOM during basic setup when
> > struct page initialisation was deferred. One approach is to initialise memory
> > on demand but it interferes with page allocator paths. This patch creates
> > dedicated threads to initialise memory before basic setup. It then blocks
> > on a rw_semaphore until completion as a wait_queue and counter is overkill.
> > This may be slower to boot but it's simplier overall and also gets rid of a
> > section mangling which existed so kswapd could do the initialisation.
> 
> Seems a reasonable compromise.  It makes a bit of a mess of the patch
> sequencing.
> 
> Have some tweaklets:
> 

The tweaks are prefectly reasonable. As for the patch sequencing, I'm ok
with adding the patch on top if you are because that preserves the testing
history. If you're unhappy, I can shuffle it into a better place and resend
the full series that includes all the fixes so far.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
