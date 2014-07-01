Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6076B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 21:08:54 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h15so4820489igd.3
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:08:53 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id m5si13940037ige.60.2014.06.30.18.08.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 18:08:53 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so4817285igq.4
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 18:08:53 -0700 (PDT)
Date: Mon, 30 Jun 2014 18:08:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mmotm:master 74/230] mm/slab.h:299:10: error: 'struct kmem_cache'
 has no member named 'node'
In-Reply-To: <alpine.DEB.2.11.1406200916070.10271@gentwo.org>
Message-ID: <alpine.DEB.2.02.1406301808190.9926@chino.kir.corp.google.com>
References: <53a38f31.ttbTrpTZnPLPRHcz%fengguang.wu@intel.com> <alpine.DEB.2.11.1406200916070.10271@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, 20 Jun 2014, Christoph Lameter wrote:

> Argh a SLOB configuration which does not use node specfic management data.
> 
> Subject: SLOB has no node specific management structures.
> 
> Do not provide the defintions for node management structures for SLOB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
