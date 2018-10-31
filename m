Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85B536B0008
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:42:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y5-v6so8413314edp.7
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:42:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14-v6si10081145edj.23.2018.10.31.09.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 09:42:33 -0700 (PDT)
Date: Wed, 31 Oct 2018 17:42:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Message-ID: <20181031164231.GQ32673@dhcp22.suse.cz>
References: <20181031081945.207709-1-vovoy@chromium.org>
 <20181031142458.GP32673@dhcp22.suse.cz>
 <cc44aa53-8705-02ea-6c59-f311427d93af@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc44aa53-8705-02ea-6c59-f311427d93af@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 31-10-18 07:40:14, Dave Hansen wrote:
> On 10/31/18 7:24 AM, Michal Hocko wrote:
> > I am also wondering whether unevictable pages culling can be
> > really visible when we do the anon LRU reclaim because the swap path is
> > quite expensinve on its own.
> 
> Didn't we create the unevictable lists in the first place because
> scanning alone was observed to be so expensive in some scenarios?

Yes, that is the case. I might just misunderstood the code I thought
those pages were already on the LRU when unevictable flag was set and
we would only move these pages to the unevictable list lazy during the
reclaim. If the flag is set at the time when the page is added to the
LRU then it should get to the proper LRU list right away. But then I do
not understand the test results from previous run at all.
-- 
Michal Hocko
SUSE Labs
