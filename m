Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 912226B026D
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:25:02 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s24-v6so12354646plp.12
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:25:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w31-v6si8334449pla.347.2018.10.31.07.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 07:25:01 -0700 (PDT)
Date: Wed, 31 Oct 2018 15:24:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Message-ID: <20181031142458.GP32673@dhcp22.suse.cz>
References: <20181031081945.207709-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181031081945.207709-1-vovoy@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Wed 31-10-18 16:19:45, Kuo-Hsin Yang wrote:
[...]
> The previous mapping_set_unevictable patch is worse on gem_syslatency
> because it defers to vmscan to move these pages to the unevictable list
> and the test measures latency to allocate 2MiB pages. This performance
> impact can be solved by explicit moving pages to the unevictable list in
> the i915 function.

As I've mentioned in the previous version and testing results. Are you
sure that the lazy unevictable pages collecting is the real problem
here? The test case was generating a lot of page cache and we simply do
not reclaim anon LRUs at all. Maybe I have misunderstood the test
though. I am also wondering whether unevictable pages culling can be
really visible when we do the anon LRU reclaim because the swap path is
quite expensinve on its own.
-- 
Michal Hocko
SUSE Labs
