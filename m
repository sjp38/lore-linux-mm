Date: Mon, 28 Aug 2006 13:49:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH RFP-V4 00/13] remap_file_pages protection support - 4th
 attempt
Message-Id: <20060828134915.f7787422.akpm@osdl.org>
In-Reply-To: <200608261933.36574.blaisorblade@yahoo.it>
References: <200608261933.36574.blaisorblade@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Jeff Dike <jdike@addtoit.com>, user-mode-linux-devel@lists.sourceforge.net, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Aug 2006 19:33:35 +0200
Blaisorblade <blaisorblade@yahoo.it> wrote:

> Again, about 4 month since last time (for lack of time) I'm sending for final 
> review and for inclusion into -mm protection support for remap_file_pages (in 
> short "RFP prot support"), i.e. setting per-pte protections (beyond file 
> offset) through this syscall.

This all looks a bit too fresh and TODO-infested for me to put it in -mm at
this time.

I could toss them in to get some testing underway, but that makes life
complex for other ongoing MM work.  (And there's a _lot_ of that - I
presently have >180 separate patches which alter ./mm/*).

Also, it looks like another round of detailed review is needed before this
work will really start to settle into its final form.

So..   I'll await version 5, sorry.   Please persist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
