Date: Tue, 17 Feb 2004 04:40:01 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040217124001.GA1267@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <20040217073522.A25921@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040217073522.A25921@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 17, 2004 at 07:35:22AM +0000, Christoph Hellwig wrote:
> On Mon, Feb 16, 2004 at 11:09:27AM -0800, Paul E. McKenney wrote:
> > Hello, Andrew,
> > 
> > The attached patch to make invalidate_mmap_range() non-GPL exported
> > seems to have been lost somewhere between 2.6.1-mm4 and 2.6.1-mm5.
> > It still applies cleanly.  Could you please take it up again?
> 
> And there's still no reason to ease IBM's GPL violations by exporting
> deep VM internals.  The GPLed DFS you claimed you needed this for still
> hasn't shown up but instead you want to change the export all the time.
> 
> Tells a lot about IBMs promises..

Hello, Christoph!

IBM shipped the promised SAN Filesystem some months ago.  The source
code for the Linux client was released under GPL, as promised, and may
be found at the following URL:

https://www6.software.ibm.com/dl/sanfsys/sanfsref-i?S_PKG=dl&S_TACT=&S_CMP=

A PDF of the protocol specification may be found at the following URL:

http://www.storage.ibm.com/software/virtualization/sfs/protocol.html

These URLs do require that you register, but there is no cost nor any
agreement other than the GPL itself.  The Linux client has not been
shipped as product yet.  The code is still quite rough, which is one
reason that it has not be submitted to, for example, LKML.  ;-)

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
