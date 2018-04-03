Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5AF6B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 03:59:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so3461262wrj.15
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 00:59:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t15si1726557wrb.190.2018.04.03.00.59.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Apr 2018 00:59:29 -0700 (PDT)
Date: Tue, 3 Apr 2018 09:59:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180403075928.GC5501@dhcp22.suse.cz>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Tue 03-04-18 13:46:28, Naoya Horiguchi wrote:
> My testing for the latest kernel supporting thp migration found out an
> infinite loop in offlining the memory block that is filled with shmem
> thps.  We can get out of the loop with a signal, but kernel should
> return with failure in this case.
> 
> What happens in the loop is that scan_movable_pages() repeats returning
> the same pfn without any progress. That's because page migration always
> fails for shmem thps.

Why does it fail? Shmem pages should be movable without any issues.

-- 
Michal Hocko
SUSE Labs
