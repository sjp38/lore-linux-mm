Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 30F926B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:12:11 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so16675915wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 02:12:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga6si33076810wjb.152.2016.03.29.02.12.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 02:12:09 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm/page_ref: use page_ref helper instead of direct
 modification of _count
References: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FA46E5.9000208@suse.cz>
Date: Tue, 29 Mar 2016 11:12:05 +0200
MIME-Version: 1.0
In-Reply-To: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/28/2016 08:30 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> page_reference manipulation functions are introduced to track down
> reference count change of the page. Use it instead of direct modification
> of _count.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
