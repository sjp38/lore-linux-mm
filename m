Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC4D06B02E6
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:08:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b34-v6so7405025edb.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:08:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c17-v6si4791625ejp.175.2018.11.06.01.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:08:40 -0800 (PST)
Date: Tue, 6 Nov 2018 10:08:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5] mm, drm/i915: mark pinned shmemfs pages as unevictable
Message-ID: <20181106090839.GE27423@dhcp22.suse.cz>
References: <20181106090352.64114-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106090352.64114-1-vovoy@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Tue 06-11-18 17:03:51, Kuo-Hsin Yang wrote:
> The i915 driver uses shmemfs to allocate backing storage for gem
> objects. These shmemfs pages can be pinned (increased ref count) by
> shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> wastes a lot of time scanning these pinned pages. In some extreme case,
> all pages in the inactive anon lru are pinned, and only the inactive
> anon lru is scanned due to inactive_ratio, the system cannot swap and
> invokes the oom-killer. Mark these pinned pages as unevictable to speed
> up vmscan.
> 
> Export pagevec API check_move_unevictable_pages().
> 
> This patch was inspired by Chris Wilson's change [1].
> 
> [1]: https://patchwork.kernel.org/patch/9768741/
> 
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> Acked-by: Michal Hocko <mhocko@suse.com>

please make it explicit that the ack applies to mm part as i've
mentioned when giving my ack to the previous version.

E.g.
Acked-by: Michal Hocko <mhocko@use.com> # mm part

because i am not familiar with the drm code to ack any changes there.
-- 
Michal Hocko
SUSE Labs
