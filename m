Date: Tue, 17 Feb 2004 07:35:22 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040217073522.A25921@infradead.org>
References: <20040216190927.GA2969@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040216190927.GA2969@us.ibm.com>; from paulmck@us.ibm.com on Mon, Feb 16, 2004 at 11:09:27AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2004 at 11:09:27AM -0800, Paul E. McKenney wrote:
> Hello, Andrew,
> 
> The attached patch to make invalidate_mmap_range() non-GPL exported
> seems to have been lost somewhere between 2.6.1-mm4 and 2.6.1-mm5.
> It still applies cleanly.  Could you please take it up again?

And there's still no reason to ease IBM's GPL violations by exporting
deep VM internals.  The GPLed DFS you claimed you needed this for still
hasn't shown up but instead you want to change the export all the time.

Tells a lot about IBMs promises..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
