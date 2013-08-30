Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id ED1846B0036
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 17:48:31 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so2831053pad.2
        for <linux-mm@kvack.org>; Fri, 30 Aug 2013 14:48:31 -0700 (PDT)
Date: Fri, 30 Aug 2013 14:48:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm/vmalloc: use NUMA_NO_NODE
In-Reply-To: <521FF39E.3040700@huawei.com>
Message-ID: <alpine.DEB.2.02.1308301448130.29484@chino.kir.corp.google.com>
References: <521FF39E.3040700@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 30 Aug 2013, Jianguo Wu wrote:

> Use more appropriate "if (node == NUMA_NO_NODE)" instead of "if (node < 0)"
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
