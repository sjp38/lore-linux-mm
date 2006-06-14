Date: Wed, 14 Jun 2006 09:14:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: zoned vm counters: per zone counter functionality
In-Reply-To: <448F64A0.9090705@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0606140914060.3919@schroedinger.engr.sgi.com>
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
 <20060612211255.20862.39044.sendpatchset@schroedinger.engr.sgi.com>
 <448E4F05.9040804@yahoo.com.au> <Pine.LNX.4.64.0606130854480.29796@schroedinger.engr.sgi.com>
 <448F64A0.9090705@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Con Kolivas <kernel@kolivas.org>, Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2006, Nick Piggin wrote:

> I guess that's OK.
> 
> Hmm, then NR_ANON would become VM_ZONE_STAT_NR_ANON? That might be a bit
> long for your tastes, maybe the prefix could be hidden by "clever" macros?

I only changed the NR_STAT_ITEMS but kept the rest since these symbols are 
used frequently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
