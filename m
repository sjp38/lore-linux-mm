Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 65A2A6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:13:40 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so1090800wib.3
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:13:39 -0800 (PST)
Received: from caramon.arm.linux.org.uk (caramon.arm.linux.org.uk. [78.32.30.218])
        by mx.google.com with ESMTPS id m18si4808468wiv.2.2013.12.12.09.13.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 09:13:39 -0800 (PST)
Date: Thu, 12 Dec 2013 17:13:22 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20131212171322.GT4360@n2100.arm.linux.org.uk>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212143149.GI12099@ldesroches-Latitude-E6320>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ludovic Desroches <ludovic.desroches@atmel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iamjoonsoo.kim@lge.com

On Thu, Dec 12, 2013 at 03:31:50PM +0100, Ludovic Desroches wrote:
> I'll investigate on atmel-mci driver side but if someone has also this
> issue or see what is wrong in the driver, please tell me all about it.

I'm not entirely sure what's causing this, but calling flush_dcache_page()
from an IRQ isn't the best idea, as one of its side effects will be to
unmask IRQs at the CPU.

BTW, the faulting function seems to have been removed in more recent
kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
