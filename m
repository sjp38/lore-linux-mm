Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 498A66B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:49:31 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id k1so4769314oag.6
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:49:31 -0800 (PST)
Received: from eusmtp01.atmel.com (eusmtp01.atmel.com. [212.144.249.242])
        by mx.google.com with ESMTPS id x6si7563984obl.88.2013.12.16.02.49.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Dec 2013 02:49:30 -0800 (PST)
Date: Mon, 16 Dec 2013 11:49:27 +0100
From: Ludovic Desroches <ludovic.desroches@atmel.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20131216104927.GA9627@ldesroches-Latitude-E6320>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
 <20131212171322.GT4360@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20131212171322.GT4360@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iamjoonsoo.kim@lge.com, Ludovic Desroches <ludovic.desroches@atmel.com>

On Thu, Dec 12, 2013 at 05:13:22PM +0000, Russell King - ARM Linux wrote:
> On Thu, Dec 12, 2013 at 03:31:50PM +0100, Ludovic Desroches wrote:
> > I'll investigate on atmel-mci driver side but if someone has also this
> > issue or see what is wrong in the driver, please tell me all about it.
> 
> I'm not entirely sure what's causing this, but calling flush_dcache_page()
> from an IRQ isn't the best idea, as one of its side effects will be to
> unmask IRQs at the CPU.
> 

Thans for pointing this point. Having a look to other mmc drivers, it
seems flush_dcache_page() is also called from an IRQ. Not sure that
deferring it is the way to go.

What should be the most proper solution?

> BTW, the faulting function seems to have been removed in more recent
> kernels.

Same error with rc4 and linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
