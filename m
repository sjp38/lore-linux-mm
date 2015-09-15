Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 480806B0256
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:32:23 -0400 (EDT)
Received: by ykft14 with SMTP id t14so35302396ykf.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:32:23 -0700 (PDT)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id l136si9177612ywe.13.2015.09.15.07.32.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:32:22 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so186950439ykd.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:32:22 -0700 (PDT)
Date: Tue, 15 Sep 2015 10:32:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 05/10] mm/percpu: Use offset_in_page macro
Message-ID: <20150915143219.GC2905@mtj.duckdns.org>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
 <1442326081-7383-1-git-send-email-kuleshovmail@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442326081-7383-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 15, 2015 at 08:08:01PM +0600, Alexander Kuleshov wrote:
> The <linux/mm.h> provides offset_in_page() macro. Let's use already
> predefined macro instead of (addr & ~PAGE_MASK).
> 
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Please feel free to route with other patches.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
