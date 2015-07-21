Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8F06B0260
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 18:31:17 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so81750901pdb.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:31:17 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id i2si46380080pdc.102.2015.07.21.15.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 15:31:16 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so55066570pab.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:31:16 -0700 (PDT)
Date: Tue, 21 Jul 2015 15:31:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/slub: allow merging when SLAB_DEBUG_FREE is set
In-Reply-To: <20150720152913.14239.69304.stgit@buzz>
Message-ID: <alpine.DEB.2.10.1507211531010.3833@chino.kir.corp.google.com>
References: <20150720152913.14239.69304.stgit@buzz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 20 Jul 2015, Konstantin Khlebnikov wrote:

> This patch fixes creation of new kmem-caches after enabling sanity_checks
> for existing mergeable kmem-caches in runtime: before that patch creation
> fails because unique name in sysfs already taken by existing kmem-cache.
> 
> Unlike to other debug options this doesn't change object layout and could
> be enabled and disabled at any time.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
