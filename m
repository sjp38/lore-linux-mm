Date: Tue, 6 Apr 2004 18:01:41 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040406160141.GX2234@dualathlon.random>
References: <20040402205410.A7194@infradead.org> <20040402203514.GR21341@dualathlon.random> <20040403094058.A13091@infradead.org> <20040403152026.GE2307@dualathlon.random> <20040403155958.GF2307@dualathlon.random> <20040403170258.GH2307@dualathlon.random> <20040405105912.A3896@infradead.org> <20040405131113.A5094@infradead.org> <20040406042222.GP2234@dualathlon.random> <20040406061646.B14800@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040406061646.B14800@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2004 at 06:16:46AM +0100, Christoph Hellwig wrote:
> Can you try the patch below (testing it now, but I'm pretty sure it'll fix it)
> instead of all the kmalloc changes?:

I'm having some email dealy so I don't know if you sent me more recent
emails, did it work fine as expected or should I keep my kmalloc change?

thanks
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
