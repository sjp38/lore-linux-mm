Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 98D826B00B7
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:09:45 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so1217168pdj.36
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:09:45 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:09:41 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 11/15] slab: remove SLAB_LIMIT
In-Reply-To: <1381913052-23875-12-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c7d2c80f-ddc771c0-b1be-4300-a264-a9a4bc6b686d-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-12-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 16 Oct 2013, Joonsoo Kim wrote:

> It's useless now, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
