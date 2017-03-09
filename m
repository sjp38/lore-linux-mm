Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90E54831FE
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 03:36:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e129so100100962pfh.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 00:36:15 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30129.outbound.protection.outlook.com. [40.107.3.129])
        by mx.google.com with ESMTPS id z4si5744983pge.359.2017.03.09.00.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 00:36:14 -0800 (PST)
Subject: Re: [PATCH] kasan: resched in quarantine_remove_cache()
References: <20170308154239.25440-1-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <8c9ee23c-635d-9b12-efcb-f0233dd508fc@virtuozzo.com>
Date: Thu, 9 Mar 2017 11:37:23 +0300
MIME-Version: 1.0
In-Reply-To: <20170308154239.25440-1-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>

On 03/08/2017 06:42 PM, Dmitry Vyukov wrote:
> We see reported stalls/lockups in quarantine_remove_cache() on machines
> with large amounts of RAM. quarantine_remove_cache() needs to scan whole
> quarantine in order to take out all objects belonging to the cache.
> Quarantine is currently 1/32-th of RAM, e.g. on a machine with 256GB
> of memory that will be 8GB. Moreover quarantine scanning is a walk
> over uncached linked list, which is slow.
> 
> Add cond_resched() after scanning of each non-empty batch of objects.
> Batches are specifically kept of reasonable size for quarantine_put().
> On a machine with 256GB of RAM we should have ~512 non-empty batches,
> each with 16MB of objects.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Greg Thelen <gthelen@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
