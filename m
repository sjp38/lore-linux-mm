Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA3506B0006
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:40:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r16-v6so11563221pgv.17
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:40:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q21-v6si6553658pgm.534.2018.10.31.07.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 07:40:16 -0700 (PDT)
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
References: <20181031081945.207709-1-vovoy@chromium.org>
 <20181031142458.GP32673@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cc44aa53-8705-02ea-6c59-f311427d93af@intel.com>
Date: Wed, 31 Oct 2018 07:40:14 -0700
MIME-Version: 1.0
In-Reply-To: <20181031142458.GP32673@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Kuo-Hsin Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/31/18 7:24 AM, Michal Hocko wrote:
> I am also wondering whether unevictable pages culling can be
> really visible when we do the anon LRU reclaim because the swap path is
> quite expensinve on its own.

Didn't we create the unevictable lists in the first place because
scanning alone was observed to be so expensive in some scenarios?

Or am I misunderstanding your question.
