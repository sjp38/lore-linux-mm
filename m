Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3A2A6B0401
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 05:00:03 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id t132so6508749lfe.12
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 02:00:03 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 81si641368lfq.41.2017.04.06.02.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 02:00:02 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id n78so3089315lfi.3
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 02:00:02 -0700 (PDT)
Date: Thu, 6 Apr 2017 11:59:58 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: re-use node VM page state enum
Message-ID: <20170406085958.GC2268@esperanza>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
 <20170404220148.28338-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404220148.28338-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Apr 04, 2017 at 06:01:47PM -0400, Johannes Weiner wrote:
> The current duplication is a high-maintenance mess, and it's painful
> to add new items or query memcg state from the rest of the VM.
> 
> This increases the size of the stat array marginally, but we should
> aim to track all these stats on a per-cgroup level anyway.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
