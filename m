From: Andi Kleen <ak@suse.de>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
Date: Tue, 13 Nov 2007 00:59:34 +0100
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711130059.34346.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 13 November 2007 00:52:14 Christoph Lameter wrote:
> Use sparsemem as the only memory model for UP, SMP and NUMA.
> 
> Measurements indicate that DISCONTIGMEM has a higher
> overhead than sparsemem. And FLATMEMs benefits are minimal. So I think its
> best to simply standardize on sparsemem.

How about the memory overhead? Is it the same too?
And code size vs flatmem?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
