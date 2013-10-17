Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCCB6B00BE
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:15:27 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so3312147pde.9
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:15:26 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:15:23 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page to
 reduce memory usage
In-Reply-To: <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
Message-ID: <00000141c7d7ff58-44f388c4-da4a-4438-84a3-a2edb161b6a4-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <20131016133457.60fa71f893cd2962d8ec6ff3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 16 Oct 2013, Andrew Morton wrote:

> This issue hasn't been well thought through.  Given a random struct
> page, there isn't any protocol to determine what it actually *is*.
> It's a plain old variant record, but it lacks the agreed-upon tag field
> which tells users which variant is currently in use.

This issue has bitten us when SLUB was first introduced. We found out the
hard way f.e. that the mapping field had meaning in various contexts for a
slab page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
