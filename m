Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 318846B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:55:52 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 124so69932465pfg.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 05:55:52 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b8si6283241pfd.34.2016.03.10.05.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 05:55:51 -0800 (PST)
Subject: Re: [PATCH] mm/mempool: Avoid KASAN marking mempool posion checks as
 use-after-free
References: <1457504179-18942-1-git-send-email-matthew@mjdsystems.ca>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <56E17CE4.7090400@virtuozzo.com>
Date: Thu, 10 Mar 2016 16:55:48 +0300
MIME-Version: 1.0
In-Reply-To: <1457504179-18942-1-git-send-email-matthew@mjdsystems.ca>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Dawson <matthew@mjdsystems.ca>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 03/09/2016 09:16 AM, Matthew Dawson wrote:
> When removing an element from the mempool, mark it as unpoisoned in KASAN
> before verifying its contents for SLUB/SLAB debugging.  Otherwise KASAN
> will flag the reads checking the element use-after-free writes as
> use-after-free reads.
> 
> Signed-off-by: Matthew Dawson <matthew@mjdsystems.ca>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
