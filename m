Date: Tue, 8 May 2007 21:08:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] optimise unlock_page
In-Reply-To: <20070508114003.GB19294@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705082054500.18925@blonde.wat.veritas.com>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-arch@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 May 2007, Nick Piggin wrote:

> This patch trades a page flag for a significant improvement in the unlock_page
> fastpath. Various problems in the previous version were spotted by Hugh and
> Ben (and fixed in this one).
> 
> Comments?

Seems there's still a bug there.  I get hangs on the page lock, on
i386 and on x86_64 and on powerpc: sometimes they unhang themselves
after a while (presume other activity does the wakeup).  Obvious even
while booting (Starting udevd).  Sorry, not had time to investigate.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
