Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB5EE6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 20:33:53 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o8T0XjWZ002329
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:33:45 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz17.hot.corp.google.com with ESMTP id o8T0Xdba025000
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:33:44 -0700
Received: by pxi12 with SMTP id 12so53914pxi.32
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:33:39 -0700 (PDT)
Date: Tue, 28 Sep 2010 17:33:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup5 1/3] slub: reduce differences between SMP and
 NUMA
In-Reply-To: <20100928131056.509118201@linux.com>
Message-ID: <alpine.DEB.2.00.1009281733001.9704@chino.kir.corp.google.com>
References: <20100928131025.319846721@linux.com> <20100928131056.509118201@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Christoph Lameter wrote:

> Reduce the #ifdefs and simplify bootstrap by making SMP and NUMA as much alike
> as possible. This means that there will be an additional indirection to get to
> the kmem_cache_node field under SMP.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

Nice cleanup!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
