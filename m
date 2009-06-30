Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E7C246B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:20:57 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3412582C54F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:39:09 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DopD3SdF11fN for <linux-mm@kvack.org>;
	Tue, 30 Jun 2009 10:39:09 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5AC0282C55B
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:38:24 -0400 (EDT)
Date: Tue, 30 Jun 2009 10:20:24 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
 in  sl[aou]b
In-Reply-To: <84144f020906292358j6517b599n471eed4e88781a78@mail.gmail.com>
Message-ID: <alpine.DEB.1.10.0906301014060.6124@gentwo.org>
References: <20090625193137.GA16861@linux.vnet.ibm.com>  <alpine.DEB.1.10.0906291827050.21956@gentwo.org>  <1246315553.21295.100.camel@calx>  <alpine.DEB.1.10.0906291910130.32637@gentwo.org>  <1246320394.21295.105.camel@calx>  <20090630060031.GL7070@linux.vnet.ibm.com>
 <84144f020906292358j6517b599n471eed4e88781a78@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: paulmck@linux.vnet.ibm.com, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009, Pekka Enberg wrote:

> I don't even claim to understand all the RCU details here but I don't
> see why we should care about _kmem_cache_destroy()_ performance at
> this level. Christoph, hmmm?

Well it was surprising to me that kmem_cache_destroy() would perform rcu
actions in the first place. RCU is usually handled externally and not
within the slab allocator. The only reason that SLAB_DESTROY_BY_RCU exists
is because the user cannot otherwise control the final release of memory
to the page allocator.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
