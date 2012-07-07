Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 1EDFF6B0074
	for <linux-mm@kvack.org>; Sat,  7 Jul 2012 04:40:27 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so19302035pbb.14
        for <linux-mm@kvack.org>; Sat, 07 Jul 2012 01:40:26 -0700 (PDT)
Date: Sat, 7 Jul 2012 01:40:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order
 0
In-Reply-To: <1341588521-17744-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 7 Jul 2012, Joonsoo Kim wrote:

> __alloc_pages_direct_compact has many arguments so invoking it is very costly.
> And in almost invoking case, order is 0, so return immediately.
> 

If "zero cost" is "very costly", then this might make sense.

__alloc_pages_direct_compact() is inlined by gcc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
