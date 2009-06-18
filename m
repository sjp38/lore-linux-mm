Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FD7D6B005D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:52:27 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3D67282C3B5
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:10:26 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TjtE5Doug8yI for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 10:10:26 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 847D082C3BD
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:10:21 -0400 (EDT)
Date: Thu, 18 Jun 2009 09:54:00 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 02/19] Introduce this_cpu_ptr() and generic
 this_cpu_* operations
In-Reply-To: <4A39A680.5070405@kernel.org>
Message-ID: <alpine.DEB.1.10.0906180953040.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org> <20090617203443.173725344@gentwo.org> <4A399D52.9040801@kernel.org> <4A39A680.5070405@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, Tejun Heo wrote:

> Oops, one problem.  this_cpu_ptr() should evaluate to the same type
> pointer as input but it currently evaulates to unsigned long.

this_cpu_ptr is uses SHIFT_PERCPU_PTR which preserves the type.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
