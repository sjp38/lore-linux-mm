From: Andi Kleen <ak@suse.de>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
Date: Tue, 13 Nov 2007 01:49:54 +0100
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com> <200711130059.34346.ak@suse.de> <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711130149.54852.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

> Hmmm... More memory free? How did that happen? More pages cached for some
> reason. The total available memory is increased by 8k.

Nice. Looks all reasonable. Thanks for the numbers.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
