Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 125666B00E6
	for <linux-mm@kvack.org>; Sun,  2 Nov 2014 23:23:04 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so10772925pdb.37
        for <linux-mm@kvack.org>; Sun, 02 Nov 2014 20:23:03 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ov3si14316452pbc.228.2014.11.02.20.23.02
        for <linux-mm@kvack.org>;
        Sun, 02 Nov 2014 20:23:02 -0800 (PST)
Date: Sun, 02 Nov 2014 23:23:00 -0500 (EST)
Message-Id: <20141102.232300.35454786891449365.davem@davemloft.net>
Subject: Re: [patch 3/3] mm: move page->mem_cgroup bad page handling into
 generic code
From: David Miller <davem@davemloft.net>
In-Reply-To: <1414898156-4741-3-git-send-email-hannes@cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
	<1414898156-4741-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Sat,  1 Nov 2014 23:15:56 -0400

> Now that the external page_cgroup data structure and its lookup is
> gone, let the generic bad_page() check for page->mem_cgroup sanity.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
