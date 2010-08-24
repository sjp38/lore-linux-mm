Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 573E96B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 13:43:20 -0400 (EDT)
Date: Tue, 24 Aug 2010 20:44:57 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
In-Reply-To: <1282663241.10679.958.camel@calx>
Message-ID: <alpine.DEB.2.00.1008242044450.2329@tiger>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>  <1282623994.10679.921.camel@calx>  <alpine.DEB.2.00.1008232134480.25742@chino.kir.corp.google.com> <1282663241.10679.958.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010, Matt Mackall wrote:
> (peeks at code)
>
> Ok, that + should be a -. But yes, you're right, the bucket around an
> order-0 allocation is quite small.
>
> Acked-by: Matt Mackall <mpm@selenic.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
