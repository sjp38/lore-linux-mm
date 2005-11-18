From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NUMA policies in the slab allocator V2
Date: Fri, 18 Nov 2005 03:59:17 +0100
References: <Pine.LNX.4.62.0511171745410.22486@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511171745410.22486@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511180359.17598.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Friday 18 November 2005 02:51, Christoph Lameter wrote:
> This patch fixes a regression in 2.6.14 against 2.6.13 that causes an
> imbalance in memory allocation during bootup.

I still think it's wrongly implemented. We shouldn't be slowing down the slab 
fast path for this. Also BTW if anything your check would need to be 
dependent on !in_interrupt(), otherwise the policy of slab allocations
in interrupt context will change randomly based on what the current
process is doing (that's wrong, interrupts should be always local)
But of course that would make the fast path even slower ...

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
