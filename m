Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id AA1C36B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 15:50:06 -0400 (EDT)
Received: by iecnq11 with SMTP id nq11so23110530iec.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 12:50:06 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id u9si96386icv.80.2015.05.06.12.50.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 12:50:06 -0700 (PDT)
Received: by ieczm2 with SMTP id zm2so23044274iec.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 12:50:06 -0700 (PDT)
Date: Wed, 6 May 2015 12:50:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: only define hashdist variable when needed
In-Reply-To: <1430753249-30850-1-git-send-email-linux@rasmusvillemoes.dk>
Message-ID: <alpine.DEB.2.10.1505061249520.10365@chino.kir.corp.google.com>
References: <1430753249-30850-1-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 4 May 2015, Rasmus Villemoes wrote:

> For !CONFIG_NUMA, hashdist will always be 0, since it's setter is
> otherwise compiled out. So we can save 4 bytes of data and some .text
> (although mostly in __init functions) by only defining it for
> CONFIG_NUMA.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
