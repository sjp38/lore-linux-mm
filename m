Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A7F7B6B0032
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 17:48:07 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so2347774pdj.39
        for <linux-mm@kvack.org>; Fri, 30 Aug 2013 14:48:06 -0700 (PDT)
Date: Fri, 30 Aug 2013 14:48:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] mm/acpi: use NUMA_NO_NODE
In-Reply-To: <521FF494.6000504@huawei.com>
Message-ID: <alpine.DEB.2.02.1308301447540.29484@chino.kir.corp.google.com>
References: <521FF494.6000504@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 30 Aug 2013, Jianguo Wu wrote:

> Use more appropriate NUMA_NO_NODE instead of -1
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
