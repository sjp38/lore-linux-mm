Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 492096B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:40:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b11so6926324wmh.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:40:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u18si180106wru.73.2017.06.27.13.40.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 13:40:37 -0700 (PDT)
Date: Tue, 27 Jun 2017 13:40:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2017-06-23-15-03 uploaded
Message-Id: <20170627134033.d6df2435117d52721d37a748@linux-foundation.org>
In-Reply-To: <CAKwiHFjfrWqa+0NhL1EHKJwmghrL52Xzn-tYJsOi1B41shCsTg@mail.gmail.com>
References: <594d905d.geNp0UO7DULvNDPS%akpm@linux-foundation.org>
	<CAC=cRTNJe5Bo-1E+3oJEbWM8Yt5SyZOhnUiC9U5OK0GWrp1E0g@mail.gmail.com>
	<c3caa911-6e40-42a8-da4d-45243fb7f4ad@suse.cz>
	<13ab3968-a7e4-add3-b050-438d462f7fc4@suse.cz>
	<CAKwiHFjfrWqa+0NhL1EHKJwmghrL52Xzn-tYJsOi1B41shCsTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Vlastimil Babka <vbabka@suse.cz>, huang ying <huang.ying.caritas@gmail.com>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz, Mark Brown <broonie@kernel.org>

On Tue, 27 Jun 2017 09:38:09 +0200 Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> >>
> >> However, the patch in mmotm seems to be missing this crucial hunk that
> >> Rasmus had in the patch he sent [1]:
> >>
> >> -__rmqueue_fallback(struct zone *zone, unsigned int order, int
> >> start_migratetype)
> >> +__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
> >>
> >> which makes this a signed vs signed comparison.
> >>
> >> What happened to it? Andrew?
> 
> This is really odd. Checking, I see that it was also absent from the
> 'this patch has been added to -mm' mail, but I admit I don't proofread
> those to see they match what I sent. Oh well. Let me know if I need to
> do anything.
> 

oops, that was me manually fixing rejects - I missed a bit.

--- a/mm/page_alloc.c~mm-page_allocc-eliminate-unsigned-confusion-in-__rmqueue_fallback-fix
+++ a/mm/page_alloc.c
@@ -2212,7 +2212,7 @@ static bool unreserve_highatomic_pageblo
  * condition simpler.
  */
 static inline bool
-__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
+__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
 	struct free_area *area;
 	int current_order;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
