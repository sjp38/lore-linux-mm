Date: Wed, 18 Feb 2004 22:21:38 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040218222138.A14585@infradead.org>
References: <20040216190927.GA2969@us.ibm.com> <20040217073522.A25921@infradead.org> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040218150607.GE1269@us.ibm.com>; from paulmck@us.ibm.com on Wed, Feb 18, 2004 at 07:06:07AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjanv@redhat.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The sys_call_table stuff was under #ifdef, and was intended for
> use by a research project that was later put out of its misery.
> This stuff has since been removed from the source tree.
> 
> As to the evilish tricks with lowlevel MM code, the whole point
> of the mmap_invalidate_range() patch is to be able to rid GPFS
> of exactly these evilish tricks.

It didn;t look like that.

Really Paul, the GPL is pretty clear on the derived work thing,
and when you need changes to the core kernel and all kinds of nasty
hacks it's pretty clear it is a derived work.

And it's up to IBM anyway to show it's not a derived work, which is
pretty hard IMHO.

I don't understand why IBM is pushing this dubious change right now,
GPL violation and thus copyright violation issues in Linux is the
last thing IBM wants to see in the press with the current mess going
on, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
