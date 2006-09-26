Date: Tue, 26 Sep 2006 08:23:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual memmap sparsity: Dealing with fragmented MAX_ORDER blocks
In-Reply-To: <451918D9.4080001@shadowen.org>
Message-ID: <Pine.LNX.4.64.0609260822190.718@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <45181B4F.6060602@shadowen.org> <Pine.LNX.4.64.0609251354460.24262@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609251643150.25159@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609251721140.25322@schroedinger.engr.sgi.com>
 <451918D9.4080001@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2006, Andy Whitcroft wrote:

> Well we'd really want it to be a page of page*'s marked as in
> PG_reserved and probabally in an invalid zone or some such to prevent
> them coelesing with logically adjacent buddies.

If we use a zero page for the memory map then we have a series of 
struct pages with the pagebuddy flag cleared. No merging will occur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
