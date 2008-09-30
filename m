Message-ID: <48E26388.30202@linux-foundation.org>
Date: Tue, 30 Sep 2008 12:36:08 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: reduce total stack usage of slab_err & object_err
References: <1222787736.2995.24.camel@castor.localdomain>	 <48E2480A.9090003@linux-foundation.org> <1222791638.2995.41.camel@castor.localdomain>
In-Reply-To: <1222791638.2995.41.camel@castor.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: penberg <penberg@cs.helsinki.fi>, mpm <mpm@selenic.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Richard Kennedy wrote:

> Yes, using vprintk is better but you still have this path :
> ( with your patch applied)
> 
> 	object_err -> slab_bug(208) -> printk(216)
> instead of 
> 	object_err -> slab_bug_message(8) -> printk(216)
> 
> unfortunately the overhead for having var_args is pretty big, at least
> on x86_64. I haven't measured it on 32 bit yet.

Really 208 bytes for a va arg parameter declaration? I expected it to be
simply a null terminated pointer list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
