Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2686B6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 11:13:08 -0400 (EDT)
Received: by igui7 with SMTP id i7so56297462igu.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:13:07 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0225.hostedemail.com. [216.40.44.225])
        by mx.google.com with ESMTP id ph5si9328271igb.81.2015.08.31.08.13.07
        for <linux-mm@kvack.org>;
        Mon, 31 Aug 2015 08:13:07 -0700 (PDT)
Date: Mon, 31 Aug 2015 11:13:04 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/3] mm, compaction: export tracepoints zone names to
 userspace
Message-ID: <20150831111304.3888a8f6@gandalf.local.home>
In-Reply-To: <55E46C8E.8070906@suse.cz>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
	<1440689044-2922-2-git-send-email-vbabka@suse.cz>
	<20150831105834.34a5e69e@gandalf.local.home>
	<55E46C8E.8070906@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Mon, 31 Aug 2015 17:02:38 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:


> >> +#define ZONE_TYPE						\
> >> +	IFDEF_ZONE_DMA(		EM (ZONE_DMA,	 "DMA"))	\
> >> +	IFDEF_ZONE_DMA32(	EM (ZONE_DMA32,	 "DMA32"))	\
> >> +				EM (ZONE_NORMAL, "Normal")	\
> >> +	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
> >> +				EMe(ZONE_MOVABLE,"Movable")
> >> +
> >
> > Hmm, have you tried to compile this with CONFIG_ZONE_HIGHMEM disabled,
> > and CONFIG_ZONE_DMA and/or CONFIG_ZONE_DMA32 enabled?
> 
> Yep, that's standard x86_64 situation (highmem disabled, dma+dma32 enabled).
> 
> > The EMe() macro must come last, as it doesn't have the ending comma and
> > the __print_symbolic() can fail to compile due to it.
> 
> Thanks to ZONE_MOVABLE being unconditional, EMe(ZONE_MOVABLE...) is 
> always last. Otherwise the macros would get even more ugly...

Ah! My mistake was to see where the end parenthesis of
IFDEF_ZONE_HIGHMEM() laid. It looked to me that it encompassed
ZONE_MOVABLE. But obviously it does not.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
