Subject: Re: [PATCH] Avoiding fragmentation through different allocator
From: James Bottomley <jejb@steeleye.com>
In-Reply-To: <20050124154927.GJ5925@logos.cnet>
References: <20050120101300.26FA5E598@skynet.csn.ul.ie>
	 <20050121142854.GH19973@logos.cnet>
	 <Pine.LNX.4.58.0501222128380.18282@skynet>
	 <20050122215949.GD26391@logos.cnet>
	 <Pine.LNX.4.58.0501241141450.5286@skynet>
	 <20050124122952.GA5739@logos.cnet> <1106585052.5513.26.camel@mulgrave>
	 <20050124154927.GJ5925@logos.cnet>
Content-Type: text/plain
Date: Mon, 24 Jan 2005 14:36:09 -0600
Message-Id: <1106598969.5513.43.camel@mulgrave>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Mel Gorman <mel@csn.ul.ie>, William Lee Irwin III <wli@holomorphy.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Grant Grundler <grundler@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-01-24 at 13:49 -0200, Marcelo Tosatti wrote:
> So is it valid to affirm that on average an operation with one SG element pointing to a 1MB 
> region is similar in speed to an operation with 16 SG elements each pointing to a 64K 
> region due to the efficient onboard SG processing? 

it's within a few percent, yes.  And the figures depend on how good the
I/O card is at it.  I can imagine there are some wildly varying I/O
cards out there.

However, also remember that 1MB of I/O is getting beyond what's sensible
for a disc device anyway.  The cable speed is much faster than the
platter speed, so the device takes the I/O into its cache as it services
it.  If you overrun the cache it will burp (disconnect) and force a
reconnection to get the rest (effectively splitting the I/O up anyway).
This doesn't apply to arrays with huge caches, but it does to pretty
much everything else.  The average disc cache size is only a megabyte or
so.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
