Date: Wed, 18 Feb 2004 21:10:35 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040218211035.A13866@infradead.org>
References: <20040216190927.GA2969@us.ibm.com> <20040217073522.A25921@infradead.org> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040218140021.GB1269@us.ibm.com>; from paulmck@us.ibm.com on Wed, Feb 18, 2004 at 06:00:21AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Arjan van de Ven <arjanv@redhat.com>, Andrew Morton <akpm@osdl.org>, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 18, 2004 at 06:00:21AM -0800, Paul E. McKenney wrote:
> There is a small shim layer required, but the bulk of the code
> implementing GPFS is common between AIX and Linux.  It was on AIX
> first by quite a few years.

Small glue layer?  Unfortunately ibm took it off the website, but
the thing is damn huge.

> > it only uses "core unix" apis ?
> 
> If they are made available, yes.  That is the point of this patch,
> after all.  ;-)

No, that's wrong.  It patches the syscall table and plays evilish
tricks with lowlevel MM code.

> > It doesn't require knowledge of deep and changing internals ? *buzz*
> 
> That is indeed the idea.

The one on the ibm website a little ago did.  You're free to upload
a new one that clearly doesn't need all this, but..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
