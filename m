Date: Thu, 19 Feb 2004 05:04:43 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219130442.GJ1269@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218153234.3956af3a.akpm@osdl.org> <20040219123237.B22406@infradead.org> <20040219105608.30d2c51e.akpm@osdl.org> <20040219190141.A26888@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040219190141.A26888@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 19, 2004 at 07:01:41PM +0000, Christoph Hellwig wrote:
> On Thu, Feb 19, 2004 at 10:56:08AM -0800, Andrew Morton wrote:
> > inter-node cache consistency.  Other distributed filesystems will need this
> > and probably AIX already provides it.
> 
> You've probably not seen the AIX VM architecture.  Good for you as it's
> not good for your stomache.  I did when I still was SCAldera and although
> my NDAs don't allow me to go into details I can tell you that the AIX
> VM architecture is deeply tied into the segment architecture of the Power
> CPU and signicicantly different from any other UNIX variant.
> 
> So porting code from AIX that touches anything VM related is a complete
> rewrite.

Or, alternatively, requires a surprisingly large glue-code layer.

							Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
