Date: Tue, 6 Apr 2004 06:14:56 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040406061456.A14800@infradead.org>
References: <20040402205410.A7194@infradead.org> <20040402203514.GR21341@dualathlon.random> <20040403094058.A13091@infradead.org> <20040403152026.GE2307@dualathlon.random> <20040403155958.GF2307@dualathlon.random> <20040403170258.GH2307@dualathlon.random> <20040405105912.A3896@infradead.org> <20040405131113.A5094@infradead.org> <20040406042222.GP2234@dualathlon.random> <20040405214330.05e4ecd7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040405214330.05e4ecd7.akpm@osdl.org>; from akpm@osdl.org on Mon, Apr 05, 2004 at 09:43:30PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2004 at 09:43:30PM -0700, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > Then there's the pagebuf_associate_memory that rings
> >  an extremely *loud* bell, pagebuf_get_no_daddr and XBUF_SET_PTR sounds
> >  even more, then I go on with xlog_get_bp and tons of other things doing
> >  pagebuf I/O with kmalloced memory with variable size of the kmalloc. Too
> >  many concidences for this not being an xfs bug.
> 
> It does pagebuf I/O with kmalloced memory?  Wow.  Pretty much anything
> which goes from kmalloc virtual addresses back to pageframes is a big fat
> warning sign.

It's for the log I/O.  I thought about doign __get_free_page for it but that
would waste a lot of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
