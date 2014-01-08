Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id D741E6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 09:18:14 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id tp5so2002932ieb.11
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 06:18:14 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.10.76.45])
        by mx.google.com with ESMTPS id n8si769649pax.160.2014.01.08.06.18.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jan 2014 06:18:10 -0800 (PST)
Date: Thu, 9 Jan 2014 01:17:49 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140109011749.6888b57d@kryten>
In-Reply-To: <20140107041939.GA20916@hacker.(null)>
References: <20140107132100.5b5ad198@kryten>
	<20140107041939.GA20916@hacker.(null)>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org


Hi Wanpeng,

> >+		if (node_spanned_pages(node)) {
> 
> s/node_spanned_pages/node_present_pages 

Thanks, I hadn't come across node_present_pages() before.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
