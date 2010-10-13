Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 70DF26B0123
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 12:10:34 -0400 (EDT)
Date: Wed, 13 Oct 2010 11:10:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <20101012182531.GH30667@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1010131109250.29099@router.home>
References: <20101005185725.088808842@linux.com> <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com> <20101012182531.GH30667@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2010, Mel Gorman wrote:

> mm/slub.c:1748: error: `cpu_info' undeclared (first use in this function)
>
> I didn't look closely yet but cpu_info is an arch-specific variable.
> Checking to see if there is a known fix yet before setting aside time to
> dig deeper.

Argh we have no arch independant way to figuring out the shared cpu mask?
The scheduler at least needs it. Need to look at it when I get back from
the conference next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
