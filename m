Date: Wed, 26 May 2004 09:06:17 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <20040526070617.GN29378@dualathlon.random>
References: <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org> <20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk> <Pine.LNX.4.58.0405250726000.9951@ppc970.osdl.org> <20040525212720.GG29378@dualathlon.random> <Pine.LNX.4.58.0405251440120.9951@ppc970.osdl.org> <20040525215500.GI29378@dualathlon.random> <Pine.LNX.4.58.0405251500250.9951@ppc970.osdl.org> <20040526021845.A1302@den.park.msu.ru> <20040525224258.GK29378@dualathlon.random> <Pine.LNX.4.58.0405251924360.15534@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405251924360.15534@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matthew Wilcox <willy@debian.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2004 at 07:26:21PM -0700, Linus Torvalds wrote:
> You're reading it wrong.
> 
> The "including when the present flag is set to zero" part does not mean 
> that the present flag was zero _before_, it means "is being set to zero" 
> as in "having been non-zero before that".

"having been non-zero before that" makes a lot more sense indeed, the
wording in the specs wasn't the best IMHO.  Interestingly the
ptep_establish at the end of handle_pte_fault would have hidden any
double fault completely, nobody but a tracer would have noticed that,
but it made very little sense that non-present entries can be cached.
It's all clear now thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
