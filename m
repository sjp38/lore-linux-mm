Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7028E6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 03:35:15 -0500 (EST)
Received: by igpw7 with SMTP id w7so85420966igp.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:35:15 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id u68si1450317ioi.25.2015.11.04.00.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 00:35:15 -0800 (PST)
Received: by pasz6 with SMTP id z6so47731781pas.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 00:35:14 -0800 (PST)
Date: Wed, 4 Nov 2015 17:36:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: change tlb_finish_mmu() to be more simple
Message-ID: <20151104083610.GA403@swordfish>
References: <1446622531-316-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446622531-316-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, raindel@mellanox.com, willy@linux.intel.com, boaz@plexistor.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (11/04/15 15:35), yalin wang wrote:
[..]
>  
> -	for (batch = tlb->local.next; batch; batch = next) {
> -		next = batch->next;
> +	for (batch = tlb->local.next; batch; batch = batch->next)
>  		free_pages((unsigned long)batch, 0);

accessing `batch->next' after calling free_pages() on `batch'?

		-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
