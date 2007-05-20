Message-ID: <4650BAB7.9090403@cs.helsinki.fi>
Date: Mon, 21 May 2007 00:16:39 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 01/10] SLUB: add support for kmem_cache_ops
References: <20070518181040.465335396@sgi.com>  <20070518181118.828853654@sgi.com> <84144f020705190553s598e722fu7279253ee8b516bc@mail.gmail.com> <Pine.LNX.4.64.0705191119010.17008@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705191119010.17008@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Yeah earlier versions did this but then I have to do a patch that changes 
> all destructors and all kmem_cache_create calls in the kernel.

Yes, please ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
