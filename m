Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 518AD6B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 17:48:56 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so2390696pdi.28
        for <linux-mm@kvack.org>; Fri, 30 Aug 2013 14:48:55 -0700 (PDT)
Date: Fri, 30 Aug 2013 14:48:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] x86/srat: use NUMA_NO_NODE
In-Reply-To: <521FF57A.8080702@huawei.com>
Message-ID: <alpine.DEB.2.02.1308301448440.29484@chino.kir.corp.google.com>
References: <521FF57A.8080702@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com

On Fri, 30 Aug 2013, Jianguo Wu wrote:

> setup_node() return NUMA_NO_NODE or valid node id(>=0), So use more appropriate
> "if (node == NUMA_NO_NODE)" instead of "if (node < 0)"
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
