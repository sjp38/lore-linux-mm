Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 934276B0263
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:59:14 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so5336090lfh.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:59:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id tj15si1920695wjb.119.2016.06.08.07.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 07:59:13 -0700 (PDT)
Date: Wed, 8 Jun 2016 10:59:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: fix documentation for compound parameter
Message-ID: <20160608145909.GB6727@cmpxchg.org>
References: <1465368216-9393-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465368216-9393-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, vdavydov@virtuozzo.com

On Wed, Jun 08, 2016 at 02:43:36PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> commit f627c2f53786 ("memcg: adjust to support new THP refcounting")
> adds a compound parameter for several functions, and change one as
> compound for mem_cgroup_move_account but it does not change the
> comments.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Thanks, that's useful.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
