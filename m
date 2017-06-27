Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 76BEC6B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:56:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s4so39972112pgr.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 14:56:47 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id d9si283860pln.48.2017.06.27.14.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Jun 2017 14:56:46 -0700 (PDT)
Date: Wed, 28 Jun 2017 07:56:42 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-06-23-15-03 uploaded
Message-ID: <20170628075642.6b3934f0@canb.auug.org.au>
In-Reply-To: <20170627134033.d6df2435117d52721d37a748@linux-foundation.org>
References: <594d905d.geNp0UO7DULvNDPS%akpm@linux-foundation.org>
	<CAC=cRTNJe5Bo-1E+3oJEbWM8Yt5SyZOhnUiC9U5OK0GWrp1E0g@mail.gmail.com>
	<c3caa911-6e40-42a8-da4d-45243fb7f4ad@suse.cz>
	<13ab3968-a7e4-add3-b050-438d462f7fc4@suse.cz>
	<CAKwiHFjfrWqa+0NhL1EHKJwmghrL52Xzn-tYJsOi1B41shCsTg@mail.gmail.com>
	<20170627134033.d6df2435117d52721d37a748@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Vlastimil Babka <vbabka@suse.cz>, huang ying <huang.ying.caritas@gmail.com>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, Mark Brown <broonie@kernel.org>

Hi Andrew,

On Tue, 27 Jun 2017 13:40:33 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> oops, that was me manually fixing rejects - I missed a bit.
> 
> --- a/mm/page_alloc.c~mm-page_allocc-eliminate-unsigned-confusion-in-__rmqueue_fallback-fix
> +++ a/mm/page_alloc.c
> @@ -2212,7 +2212,7 @@ static bool unreserve_highatomic_pageblo
>   * condition simpler.
>   */
>  static inline bool
> -__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> +__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  {
>  	struct free_area *area;
>  	int current_order;
> _
> 

I have pushed that into the original patch in linux-next for today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
