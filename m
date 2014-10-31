Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B28D6280050
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 17:11:34 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id l18so7311351wgh.38
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 14:11:34 -0700 (PDT)
Received: from ns.iliad.fr (ns.iliad.fr. [212.27.33.1])
        by mx.google.com with ESMTPS id ce6si3726367wjb.126.2014.10.31.14.11.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Oct 2014 14:11:33 -0700 (PDT)
Message-ID: <1414789630.14835.49.camel@sakura.staff.proxad.net>
Subject: Re: DMA allocations from CMA and fatal_signal_pending check
From: Maxime Bizon <mbizon@freebox.fr>
Reply-To: mbizon@freebox.fr
Date: Fri, 31 Oct 2014 22:07:10 +0100
In-Reply-To: <20141031082818.GB14642@js1304-P5Q-DELUXE>
References: <544FE9BE.6040503@gmail.com>
	 <20141031082818.GB14642@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, lauraa@codeaurora.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org, mina86@mina86.com, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com, Gregory Fong <gregory.0xf0@gmail.com>, gioh.kim@lge.com, akpm@linux-foundation.org, Brian Norris <computersforpeace@gmail.com>, linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com


On Fri, 2014-10-31 at 17:28 +0900, Joonsoo Kim wrote:

> I guess that it is okay that bcm_sysport_open() return -EINTR?

actually, since CMA alloc is hidden behind dma_alloc_coherent(), all you
get back is NULL and then return ENOMEM.

-- 
Maxime


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
