Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id DF57D6B0037
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:21:44 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id i17so1107199qcy.8
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:21:44 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id t9si7833466qct.17.2014.05.07.07.21.42
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 07:21:43 -0700 (PDT)
Date: Wed, 7 May 2014 09:21:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 01/10] slab: add unlikely macro to help compiler
In-Reply-To: <1399442780-28748-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1405070921280.12543@gentwo.org>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com> <1399442780-28748-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Wed, 7 May 2014, Joonsoo Kim wrote:

> slab_should_failslab() is called on every allocation, so to optimize it
> is reasonable. We normally don't allocate from kmem_cache. It is just
> used when new kmem_cache is created, so it's very rare case. Therefore,
> add unlikely macro to help compiler optimization.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
