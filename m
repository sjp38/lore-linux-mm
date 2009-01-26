Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C67F36B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 03:48:30 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090123154653.GA14517@wotan.suse.de>
References: <20090123154653.GA14517@wotan.suse.de>
Date: Mon, 26 Jan 2009 10:48:26 +0200
Message-Id: <1232959706.21504.7.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Fri, 2009-01-23 at 16:46 +0100, Nick Piggin wrote:
> Since last time, fixed bugs pointed out by Hugh and Andi, cleaned up the
> code suggested by Ingo (haven't yet incorporated Ingo's last patch).
> 
> Should have fixed the crash reported by Yanmin (I was able to reproduce it
> on an ia64 system and fix it).
> 
> Significantly reduced static footprint of init arrays, thanks to Andi's
> suggestion.
> 
> Please consider for trial merge for linux-next.

I merged a the one you resent privately as this one didn't apply at all.
The code is in topic/slqb/core branch of slab.git and should appear in
linux-next tomorrow.

Testing and especially performance testing is welcome. If any of the HPC
people are reading this, please do give SLQB a good beating as Nick's
plan is to replace both, SLAB and SLUB, with it in the long run. As
Christoph has expressed concerns over latency issues of SLQB, I suppose
it would be interesting to hear if it makes any difference to the
real-time folks.

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
