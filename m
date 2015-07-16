Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED732802C9
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:27:45 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so2155235igc.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:27:45 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id pq8si5555290icb.20.2015.07.15.17.27.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:27:45 -0700 (PDT)
Received: by iggf3 with SMTP id f3so2072093igg.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:27:45 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:27:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/slub: fix slab double-free in case of duplicate
 sysfs filename
In-Reply-To: <20150714131704.21442.17939.stgit@buzz>
Message-ID: <alpine.DEB.2.10.1507151727320.9230@chino.kir.corp.google.com>
References: <20150714131704.21442.17939.stgit@buzz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 14 Jul 2015, Konstantin Khlebnikov wrote:

> sysfs_slab_add() shouldn't call kobject_put at error path: this puts
> last reference of kmem-cache kobject and frees it. Kmem cache will be
> freed second time at error path in kmem_cache_create().
> 
> For example this happens when slub debug was enabled in runtime and
> somebody creates new kmem cache:
> 
> # echo 1 | tee /sys/kernel/slab/*/sanity_checks
> # modprobe configfs
> 
> "configfs_dir_cache" cannot be merged because existing slab have debug and
> cannot create new slab because unique name ":t-0000096" already taken.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
