Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 38C5F6B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:57:06 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so922433igb.15
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 06:57:06 -0700 (PDT)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id u6si21191283ico.60.2014.10.22.06.57.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 06:57:05 -0700 (PDT)
Date: Wed, 22 Oct 2014 08:57:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab_common: don't check for duplicate cache names
In-Reply-To: <alpine.LRH.2.02.1410211958030.19625@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.11.1410220856450.8892@gentwo.org>
References: <alpine.LRH.2.02.1410211958030.19625@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 21 Oct 2014, Mikulas Patocka wrote:

> 12220dea07f1ac6ac717707104773d771c3f3077), therefore we need stop checking
> for duplicate names even for the SLAB subsystem. This patch fixes the bug
> by removing the check.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
