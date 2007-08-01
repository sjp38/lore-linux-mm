From: Andi Kleen <ak@suse.de>
Subject: Re: [rfc] balance-on-fork NUMA placement
Date: Wed, 1 Aug 2007 10:39:23 +0200
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de> <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708011039.23356.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 01 August 2007 01:40:18 Christoph Lameter wrote:
 
> It does in the sense that slabs are allocated following policies. If you 
> want to place individual objects then you need to use kmalloc_node().

Nick wants to place individual objects here

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
