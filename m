Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6EB296B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 06:06:33 -0400 (EDT)
Date: Wed, 24 Jun 2009 13:08:09 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak: Early log buffer exceeded
Message-ID: <20090624100809.GA3299@localdomain.by>
References: <20090623212648.GA9502@localdomain.by>
 <1245836105.16283.13.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245836105.16283.13.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/24/09 10:35), Catalin Marinas wrote:
> > So, my questions are:
> > 1. Is 200 really enough? Why 200 not 512, 1024 (for example)?
> 
> It seems that in your case it isn't. It is fine on the machines I tested
> it on but choosing this figure wasn't too scientific.
> 
> I initially had it bigger and marked with the __init attribute to free
> it after initialisation but this was causing (harmless) section mismatch
> warnings.
>
Hello. 

Why not configure it?

//EXAMPLE
config DEBUG_KMEMLEAK_EARLY_LOG_SIZE
	int "Maximum early log entries"
	range 200 2000
	default "300"
	depends on DEBUG_KMEMLEAK
	help
	  Specify early_log size (200,400,etc.).

kmemleak.c
static struct early_log early_log[CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE];

(Well, CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE is a bit ugly.)


> What kind of hardware do you have?
>
Most of time - ASUS F3Jc laptop.

 
> > 2. When (crt_early_log >= ARRAY_SIZE(early_log)) == 1 we just can see stack.
> > Since we have "full" early_log maybe it'll be helpfull to see it?
> 
> I recall allocating this dynamically didn't work properly but I'll give
> it another try. Otherwise, I can make it configurable and print a better
> message (probably without the stack dump).
> 
> -- 
> Catalin
> 

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
