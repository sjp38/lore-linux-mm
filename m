Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A02D16B0062
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:58:29 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4BDA682C323
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:16:41 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w8mGu28IuSJi for <linux-mm@kvack.org>;
	Thu, 18 Jun 2009 10:16:41 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5C1AC82C3C5
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:16:28 -0400 (EDT)
Date: Thu, 18 Jun 2009 10:00:07 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [this_cpu_xx V2 16/19] this_cpu: slub aggressive use of this_cpu
 operations in the hotpaths
In-Reply-To: <1245306801.12010.10.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0906180959500.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org>  <20090617203445.892030202@gentwo.org> <1245306801.12010.10.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>



> On an unrelated note, it sure would be nice if the SLUB allocator didn't
> have to disable interrupts because then we could just get rid of the gfp
> masking there completely.

Right there are a number of good effects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
