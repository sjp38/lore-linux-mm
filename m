Message-ID: <47AD8DC6.30506@cosmosbay.com>
Date: Sat, 09 Feb 2008 12:25:58 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [git pull] more SLUB updates for 2.6.25
References: <Pine.LNX.4.64.0802071755580.7473@schroedinger.engr.sgi.com> <200802081812.22513.nickpiggin@yahoo.com.au> <47AC04CD.9090407@cosmosbay.com> <Pine.LNX.4.64.0802080008560.22689@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802080008560.22689@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> On Fri, 8 Feb 2008, Eric Dumazet wrote:
> 
>> And SLAB/SLUB allocators, even if only used from process context, want to
>> disable/re-enable interrupts...
> 
> Not any more..... The new fastpath does allow avoiding interrupt 
> enable/disable and we will be hopefully able to increase the scope of that 
> over time.
> 
> 

Oh, I missed this new SLUB_FASTPATH stuff (not yet in net-2.6), thanks Christoph !

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
