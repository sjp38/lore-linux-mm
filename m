Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id CC4156B006E
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 14:22:04 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so4538458lab.34
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:22:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qy3si15588074lbb.3.2014.10.20.11.22.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 11:22:02 -0700 (PDT)
Date: Mon, 20 Oct 2014 14:21:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] memcg: remove activate_kmem_mutex
Message-ID: <20141020182153.GA11973@phnom.home.cmpxchg.org>
References: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 20, 2014 at 07:11:29PM +0400, Vladimir Davydov wrote:
> The activate_kmem_mutex is used to serialize memcg.kmem.limit updates,
> but we already serialize them with memcg_limit_mutex so let's remove the
> former.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

It hid well behind this obscure name, but that's really all it seems
to do.  Away it goes!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
