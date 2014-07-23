Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5E94A6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 19:13:56 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so1607363iec.40
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 16:13:56 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id e11si46441159igq.23.2014.07.23.16.13.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 16:13:55 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so1625303iec.30
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 16:13:55 -0700 (PDT)
Date: Wed, 23 Jul 2014 16:13:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: fix the alias count(via sysfs) of slab cache
In-Reply-To: <1406087381-21400-1-git-send-email-guz.fnst@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1407231612290.1389@chino.kir.corp.google.com>
References: <1406087381-21400-1-git-send-email-guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Jul 2014, Gu Zheng wrote:

> We mark some slabs(e.g. kmem_cache_node) as unmergeable via setting
> refcount to -1, and their alias should be 0, not refcount-1, so correct
> it here.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

s/slabs/slab caches/

The two slab caches of interest are kmem_cache and kmem_cache_node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
