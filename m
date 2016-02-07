Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CF4E0830AE
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 13:33:55 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id c10so30831258pfc.2
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 10:33:55 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id r20si40503889pfa.201.2016.02.07.10.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 10:33:54 -0800 (PST)
Date: Sun, 7 Feb 2016 21:33:38 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 1/2] mm: migrate: consolidate mem_cgroup_migrate() calls
Message-ID: <20160207183337.GA19151@esperanza>
References: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454616467-8994-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mateusz Guzik <mguzik@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Feb 04, 2016 at 03:07:46PM -0500, Johannes Weiner wrote:
> Rather than scattering mem_cgroup_migrate() calls all over the place,
> have a single call from a safe place where every migration operation
> eventually ends up in - migrate_page_copy().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Suggested-by: Hugh Dickins <hughd@google.com>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
