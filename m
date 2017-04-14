Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 740AA6B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 10:59:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p133so4409069wmd.17
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 07:59:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o62si3716877wmb.56.2017.04.14.07.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 07:59:07 -0700 (PDT)
Date: Fri, 14 Apr 2017 10:58:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v8 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170414145856.GA9812@cmpxchg.org>
References: <20170406053515.4842-1-ying.huang@intel.com>
 <20170406053515.4842-2-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170406053515.4842-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Hi Huang,

I reviewed this patch based on the feedback I already provided, but
eventually gave up and rewrote it. Please take review feedback more
seriously in the future.

Attached below is the reworked patch. Most changes are to the layering
(page functions, cluster functions, range functions) so that we don't
make the lowest swap range code require a notion of huge pages, or
make the memcg page functions take size information that can be
gathered from the page itself. I turned the config symbol into a
generic THP_SWAP that can later be extended when we add 2MB IO. The
rest is function naming, #ifdef removal etc.

Please review whether this is an acceptable version for you.

Thanks

---
