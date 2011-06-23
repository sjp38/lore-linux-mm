Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A1809900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 16:24:18 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p5NKODvs002396
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 13:24:14 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz17.hot.corp.google.com with ESMTP id p5NKO7gU006701
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 13:24:12 -0700
Received: by pzk9 with SMTP id 9so1388966pzk.19
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 13:24:07 -0700 (PDT)
Date: Thu, 23 Jun 2011 13:24:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
In-Reply-To: <alpine.DEB.2.00.1106230934250.19668@router.home>
Message-ID: <alpine.DEB.2.00.1106231323470.32059@chino.kir.corp.google.com>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc> <alpine.DEB.2.00.1106141614480.10017@router.home> <alpine.DEB.2.00.1106221641120.14635@chino.kir.corp.google.com> <alpine.DEB.2.00.1106230934250.19668@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 23 Jun 2011, Christoph Lameter wrote:

> Subject: slab allocators: Provide generic description of alignment defines
> 
> Provide description for alignment defines.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
