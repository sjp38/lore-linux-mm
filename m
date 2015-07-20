Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6C98A9003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 11:37:39 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so114374216qkd.3
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:37:39 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id z65si24558621qhd.115.2015.07.20.08.37.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 08:37:38 -0700 (PDT)
Date: Mon, 20 Jul 2015 10:37:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm/slub: allow merging when SLAB_DEBUG_FREE is set
In-Reply-To: <20150720152913.14239.69304.stgit@buzz>
Message-ID: <alpine.DEB.2.11.1507201037220.15495@east.gentwo.org>
References: <20150720152913.14239.69304.stgit@buzz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 20 Jul 2015, Konstantin Khlebnikov wrote:

> This patch fixes creation of new kmem-caches after enabling sanity_checks
> for existing mergeable kmem-caches in runtime: before that patch creation
> fails because unique name in sysfs already taken by existing kmem-cache.
>
> Unlike to other debug options this doesn't change object layout and could
> be enabled and disabled at any time.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
