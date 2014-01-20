Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id E87E36B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 06:28:44 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so3057939ead.8
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:28:44 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id n47si1762162eey.119.2014.01.20.03.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 03:28:43 -0800 (PST)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 20 Jan 2014 11:28:42 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id C39F82190069
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:28:37 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0KBSRnM36831314
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:28:27 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0KBScPl013271
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:28:38 -0700
Date: Mon, 20 Jan 2014 12:28:35 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
Message-ID: <20140120122835.35e6d366@lilie>
In-Reply-To: <20140117133831.2a9306a03f9c6174ff096e48@linux-foundation.org>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
	<20140117133831.2a9306a03f9c6174ff096e48@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>


Am Fri, 17 Jan 2014 13:38:31 -0800
schrieb Andrew Morton <akpm@linux-foundation.org>:

> Yes, that is a bit of an eyesore.  We often approach the problem this
> way, which is nicer:

> [ ... ]
> #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> 	{
> 		phys_addr_t size;
> 
> 		[ ... ]
>	}
> #endif

This is a very nice idea! I have updated my fix. This leads to a V5
patch series (which I will post now) because the following to patches
had to be slightly updated
to fit on top of the fix.

Kind regards

Philipp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
