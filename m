Date: Thu, 27 Dec 2007 16:15:19 -0800 (PST)
Message-Id: <20071227.161519.78953090.davem@davemloft.net>
Subject: Re: [PATCH 01/10] percpu: Use a kconfig variable to signal arch
 specific percpu setup
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071228001047.036858000@sgi.com>
References: <20071228001046.854702000@sgi.com>
	<20071228001047.036858000@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: travis@sgi.com
Date: Thu, 27 Dec 2007 16:10:47 -0800
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, ak@suse.de
List-ID: <linux-mm.kvack.org>

> V1->V2:
> - Use def_bool as suggested by Randy.
> 
> The use of the __GENERIC_PERCPU is a bit problematic since arches
> may want to run their own percpu setup while using the generic
> percpu definitions. Replace it through a kconfig variable.
> 
> 
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Andi Kleen <ak@suse.de>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Mike Travis <travis@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
