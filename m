Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 684E860079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 16:38:18 -0500 (EST)
Subject: Re: [PATCH] [19/31] mm: export stable page flags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20091209020042.GA7751@localhost>
References: <200912081016.198135742@firstfloor.org>
	 <20091208211635.7965AB151F@basil.firstfloor.org>
	 <1260311251.31323.129.camel@calx>  <20091209020042.GA7751@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 09 Dec 2009 15:38:08 -0600
Message-ID: <1260394688.24459.991.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-12-09 at 10:00 +0800, Wu Fengguang wrote:
> On Wed, Dec 09, 2009 at 06:27:31AM +0800, Matt Mackall wrote:
> > On Tue, 2009-12-08 at 22:16 +0100, Andi Kleen wrote:
> > > From: Wu Fengguang <fengguang.wu@intel.com>
> > > 
> > > Rename get_uflags() to stable_page_flags() and make it a global function
> > > for use in the hwpoison page flags filter, which need to compare user
> > > page flags with the value provided by user space.
> > > 
> > > Also move KPF_* to kernel-page-flags.h for use by user space tools.
> > > 
> > > CC: Matt Mackall <mpm@selenic.com>
> > > CC: Nick Piggin <npiggin@suse.de>
> > > CC: Christoph Lameter <cl@linux-foundation.org>
> > > CC: Andi Kleen <andi@firstfloor.org>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > Acked-by: Matt Mackall <mpm@selenic.com>
> 
> Andi and Matt,
> 
> Sorry the stable_page_flags() will be undefined on
> !CONFIG_PROC_PAGE_MONITOR (it is almost always on,
> except for some embedded systems).
> 
> Currently the easy solution is to add a Kconfig dependency to
> CONFIG_PROC_PAGE_MONITOR.  When there comes more users (ie. some
> ftrace event), we can then always compile in stable_page_flags().

No objections.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
