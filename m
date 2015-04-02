Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 679716B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 17:38:21 -0400 (EDT)
Received: by iedm5 with SMTP id m5so79577390ied.3
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 14:38:21 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id gk7si5803947icb.93.2015.04.02.14.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 14:38:20 -0700 (PDT)
Received: by igbqf9 with SMTP id qf9so84061723igb.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 14:38:20 -0700 (PDT)
Date: Thu, 2 Apr 2015 14:38:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, mempool: use '%zu' for printing 'size_t' variable
In-Reply-To: <1427975381-5044-1-git-send-email-festevam@gmail.com>
Message-ID: <alpine.DEB.2.10.1504021437160.6935@chino.kir.corp.google.com>
References: <1427975381-5044-1-git-send-email-festevam@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabio Estevam <festevam@gmail.com>
Cc: fengguang.wu@intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Fabio Estevam <fabio.estevam@freescale.com>

On Thu, 2 Apr 2015, Fabio Estevam wrote:

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Commit 8b65aaa9c53404 ("mm, mempool: poison elements backed by page allocator") 
> caused the following build warning on ARM:
> 
> mm/mempool.c:31:2: warning: format '%ld' expects argument of type 'long int', but argument 3 has type 'size_t' [-Wformat]
> 
> Use '%zu' for printing 'size_t' variable.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Acked-by: David Rientjes <rientjes@google.com>

Fixes the mmotm:master warning reported by Fengguang on microblaze today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
