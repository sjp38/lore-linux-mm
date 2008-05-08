Date: Thu, 8 May 2008 18:51:11 +0200
From: Hans Rosenfeld <hans.rosenfeld@amd.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
Message-ID: <20080508165111.GI12654@escobedo.amd.com>
References: <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org> <Pine.LNX.4.64.0805062043580.11647@blonde.site> <20080506202201.GB12654@escobedo.amd.com> <1210106579.4747.51.camel@nimitz.home.sr71.net> <20080508143453.GE12654@escobedo.amd.com> <1210258350.7905.45.camel@nimitz.home.sr71.net> <20080508151145.GG12654@escobedo.amd.com> <1210261882.7905.49.camel@nimitz.home.sr71.net> <20080508161925.GH12654@escobedo.amd.com> <20080508163352.GN23990@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080508163352.GN23990@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 09:33:52AM -0700, Nishanth Aravamudan wrote:
> So this seems to lend credence to Dave's hypothesis. Without, as you
> were trying before, teaching pagemap all about hugepages, what are our
> options?
> 
> Can we just skip over the current iteration of the PMD loop (would we
> need something similar for the PTE loop for power?) if pmd_huge(pmd)?

Allowing huge pages in the page walker would affect both walk_pmd_range
and walk_pud_range. Then either the users of the page walker need to
know how to handle huge pages themselves (in the pmd_entry and pud_entry
callback functions), or the page walker treats huge pages as any other
pages (calling the pte_entry callback function).


-- 
%SYSTEM-F-ANARCHISM, The operating system has been overthrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
