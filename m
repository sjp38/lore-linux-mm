Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 147676B006E
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 10:31:06 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so28890059pab.34
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 07:31:05 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wn6si83923987pac.222.2015.01.05.07.31.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 07:31:04 -0800 (PST)
Date: Mon, 5 Jan 2015 18:30:54 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: track move_lock state internally
Message-ID: <20150105153054.GA31111@esperanza>
References: <1420232327-13316-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1420232327-13316-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 02, 2015 at 03:58:47PM -0500, Johannes Weiner wrote:
> The complexity of memcg page stat synchronization is currently leaking
> into the callsites, forcing them to keep track of the move_lock state
> and the IRQ flags.  Simplify the API by tracking it in the memcg.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
