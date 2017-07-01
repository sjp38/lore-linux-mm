Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9B76B0279
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 12:28:31 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l125so13315930lfg.15
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 09:28:31 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 23si4710825ljw.22.2017.07.01.09.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jul 2017 09:28:29 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id f28so12121269lfi.3
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 09:28:29 -0700 (PDT)
Date: Sat, 1 Jul 2017 19:28:25 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v4 1/2] mm/list_lru.c: fix list_lru_count_node() to be
 race free
Message-ID: <20170701162825.2gravl52jm4ggtzj@esperanza>
References: <20170628171854.t4sjyjv55j673qzv@esperanza>
 <1498707555-30525-1-git-send-email-stummala@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498707555-30525-1-git-send-email-stummala@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, Jun 29, 2017 at 09:09:15AM +0530, Sahitya Tummala wrote:
> list_lru_count_node() iterates over all memcgs to get
> the total number of entries on the node but it can race with
> memcg_drain_all_list_lrus(), which migrates the entries from
> a dead cgroup to another. This can return incorrect number of
> entries from list_lru_count_node().
> 
> Fix this by keeping track of entries per node and simply return
> it in list_lru_count_node().
> 
> Signed-off-by: Sahitya Tummala <stummala@codeaurora.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
