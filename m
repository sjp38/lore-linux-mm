Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 99C246B0033
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 22:35:34 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so5371364pbc.35
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:35:34 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so4557061pad.9
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:35:31 -0700 (PDT)
Date: Tue, 24 Sep 2013 19:35:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Resend with ACK][PATCH] mm/arch: use NUMA_NODE
In-Reply-To: <524019D0.9070706@huawei.com>
Message-ID: <alpine.DEB.2.02.1309241935190.26187@chino.kir.corp.google.com>
References: <524019D0.9070706@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Mon, 23 Sep 2013, Jianguo Wu wrote:

> Use more appropriate NUMA_NO_NODE instead of -1 in all archs' module_alloc()
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> Acked-by: Ralf Baechle <ralf@linux-mips.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
