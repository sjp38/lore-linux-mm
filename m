Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1292E6B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 15:59:37 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so30943931pad.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 12:59:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id iv8si5103515pbc.17.2015.05.28.12.59.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 12:59:36 -0700 (PDT)
Date: Thu, 28 May 2015 12:59:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: do not call reclaim if !__GFP_WAIT
Message-Id: <20150528125934.198f57db4c5daf19dd15b184@linux-foundation.org>
In-Reply-To: <1432833966-25538-1-git-send-email-vdavydov@parallels.com>
References: <1432833966-25538-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Thu, 28 May 2015 20:26:06 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> When trimming memcg consumption excess (see memory.high), we call
> try_to_free_mem_cgroup_pages without checking if we are allowed to sleep
> in the current context, which can result in a deadlock. Fix this.

Why does it deadlock?  try_to_free_mem_cgroup_pages() is passed the
gfp_mask and should honour its __GFP_WAIT setting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
