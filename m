Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39B836B003D
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 17:48:38 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id uo5so177596pbc.38
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 14:48:37 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id ub8si277866pac.213.2014.03.04.14.48.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 14:48:36 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so183895pbc.13
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 14:48:36 -0800 (PST)
Date: Tue, 4 Mar 2014 14:48:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab_common: fix the check for duplicate slab names
In-Reply-To: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.02.1403041448190.5421@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Jonathan Brassow <jbrassow@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com

On Tue, 4 Mar 2014, Mikulas Patocka wrote:

> The patch 3e374919b314f20e2a04f641ebc1093d758f66a4 is supposed to fix the
> problem where kmem_cache_create incorrectly reports duplicate cache name
> and fails. The problem is described in the header of that patch.
> 
> However, the patch doesn't really fix the problem because of these
> reasons:
> 
> * the logic to test for debugging is reversed. It was intended to perform
>   the check only if slub debugging is enabled (which implies that caches
>   with the same parameters are not merged). Therefore, there should be
>   #if !defined(CONFIG_SLUB) || defined(CONFIG_SLUB_DEBUG_ON)
>   The current code has the condition reversed and performs the test if
>   debugging is disabled.
> 
> * slub debugging may be enabled or disabled based on kernel command line,
>   CONFIG_SLUB_DEBUG_ON is just the default settings. Therefore the test
>   based on definition of CONFIG_SLUB_DEBUG_ON is unreliable.
> 
> This patch fixes the problem by removing the test
> "!defined(CONFIG_SLUB_DEBUG_ON)". Therefore, duplicate names are never
> checked if the SLUB allocator is used.
> 
> Note to stable kernel maintainers: when backporint this patch, please
> backport also the patch 3e374919b314f20e2a04f641ebc1093d758f66a4.
> 
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
