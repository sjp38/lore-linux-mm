Date: Wed, 17 Aug 2005 16:30:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: pagefault scalability patches
Message-Id: <20050817163030.15e819dd.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	<Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> Numbers:
> 
> Unpatched:
> 
>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>  16   3    1    0.757s     62.772s  63.052s 49515.393  49522.112
> 
> ...
>
> Page fault patches
> 
>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>   4   3    1    0.153s     12.314s  12.047s 63077.153  63065.474

With what workload, on what hardware?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
