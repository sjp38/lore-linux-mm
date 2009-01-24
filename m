Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E19406B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 21:38:56 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator (try 2)
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20090123154653.GA14517@wotan.suse.de>
References: <20090123154653.GA14517@wotan.suse.de>
Content-Type: text/plain
Date: Sat, 24 Jan 2009 10:38:46 +0800
Message-Id: <1232764726.11429.185.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-23 at 16:46 +0100, Nick Piggin wrote:
> Hi,
> 
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
When applying the patch to 2.6.29-rc2, I got:
[ymzhang@lkp-h01 linux-2.6.29-rc2_slqb0123]$ patch -p1<../patch-slqb0123
patching file include/linux/rcupdate.h
patching file include/linux/slqb_def.h
patching file init/Kconfig
patching file lib/Kconfig.debug
patching file mm/slqb.c
patch: **** malformed patch at line 4042: Index: linux-2.6/include/linux/slab.h


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
