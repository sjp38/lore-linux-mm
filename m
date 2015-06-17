Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFCD6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:21:04 -0400 (EDT)
Received: by igbiq7 with SMTP id iq7so79130678igb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:21:04 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id y82si4543683ioi.106.2015.06.17.16.21.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 16:21:04 -0700 (PDT)
Received: by iebgx4 with SMTP id gx4so44142052ieb.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:21:04 -0700 (PDT)
Date: Wed, 17 Jun 2015 16:21:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 2/5] mm/mempool: allow NULL `pool' pointer in
 mempool_destroy()
In-Reply-To: <1433851493-23685-3-git-send-email-sergey.senozhatsky@gmail.com>
Message-ID: <alpine.DEB.2.10.1506171619370.8203@chino.kir.corp.google.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <1433851493-23685-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Tue, 9 Jun 2015, Sergey Senozhatsky wrote:

> mempool_destroy() does not tolerate a NULL mempool_t pointer
> argument and performs a NULL-pointer dereference. This requires
> additional attention and effort from developers/reviewers and
> forces all mempool_destroy() callers to do a NULL check
> 
> 	if (pool)
> 		mempool_destroy(pool);
> 
> Or, otherwise, be invalid mempool_destroy() users.
> 
> Tweak mempool_destroy() and NULL-check the pointer there.
> 
> Proposed by Andrew Morton.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> LKML-reference: https://lkml.org/lkml/2015/6/8/583

Acked-by: David Rientjes <rientjes@google.com>

I like how your patch series is enabling us to remove many lines from the 
source code.  But doing s/Reported-by/Suggested-by/ can also make your 
changelog two lines shorter ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
