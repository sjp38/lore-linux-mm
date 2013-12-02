Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id 70CBB6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 14:45:27 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id 1so11619628qee.38
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 11:45:27 -0800 (PST)
Received: from a193-30.smtp-out.amazonses.com (a193-30.smtp-out.amazonses.com. [199.255.193.30])
        by mx.google.com with ESMTP id b15si23978391qey.134.2013.12.02.11.45.26
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 11:45:26 -0800 (PST)
Date: Mon, 2 Dec 2013 19:45:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 3/5] slab: restrict the number of objects in a slab
In-Reply-To: <1385974183-31423-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000142b4d806ec-106a9e18-afdc-404a-8aa0-4f09cfa743e8-000000@email.amazonses.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com> <1385974183-31423-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, 2 Dec 2013, Joonsoo Kim wrote:

> If page size is rather larger than 4096, above assumption would be wrong.
> In this case, we would fall back on 2 bytes sized index.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
