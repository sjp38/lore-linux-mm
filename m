Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 101C960021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 19:50:32 -0500 (EST)
Date: Mon, 7 Dec 2009 17:50:29 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-ID: <20091208005028.GF9482@parisc-linux.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, tj@kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 07, 2009 at 03:35:52PM -0800, Andrew Morton wrote:
> erk.  So does 2.6.32's vmalloc() actually work correctly on ia64?
> 
> Perhaps vmalloc_end wasn't a well chosen name for an arch-specific
> global variable.

Can we enable -Wshadow now?  Please?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
