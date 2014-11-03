Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B36656B009D
	for <linux-mm@kvack.org>; Sun,  2 Nov 2014 23:22:56 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id p10so10698063pdj.5
        for <linux-mm@kvack.org>; Sun, 02 Nov 2014 20:22:56 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id og8si14402620pbb.128.2014.11.02.20.22.54
        for <linux-mm@kvack.org>;
        Sun, 02 Nov 2014 20:22:55 -0800 (PST)
Date: Sun, 02 Nov 2014 23:22:52 -0500 (EST)
Message-Id: <20141102.232252.289821233794405148.davem@davemloft.net>
Subject: Re: [patch 2/3] mm: page_cgroup: rename file to mm/swap_cgroup.c
From: David Miller <davem@davemloft.net>
In-Reply-To: <1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
	<1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Sat,  1 Nov 2014 23:15:55 -0400

> Now that the external page_cgroup data structure and its lookup is
> gone, the only code remaining in there is swap slot accounting.
> 
> Rename it and move the conditional compilation into mm/Makefile.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
