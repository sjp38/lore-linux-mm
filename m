Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0DCB6B000D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:31:58 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id t15-v6so11801690ybl.20
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:31:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 140-v6sor1753848ywf.180.2018.10.15.15.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 15:31:58 -0700 (PDT)
Received: from mail-yw1-f47.google.com (mail-yw1-f47.google.com. [209.85.161.47])
        by smtp.gmail.com with ESMTPSA id r5-v6sm4918537ywr.80.2018.10.15.15.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 15:31:57 -0700 (PDT)
Received: by mail-yw1-f47.google.com with SMTP id 135-v6so8153544ywo.8
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:31:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <153922180696.838512.12621709717839260874.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153922180696.838512.12621709717839260874.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 15 Oct 2018 15:25:47 -0700
Message-ID: <CAGXu5j+PStxYhiJaWM-mt4+WWbS_WAfvyHoyZYD5ndDLN2SY6w@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] mm: Shuffle initial free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 10, 2018 at 6:36 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> caches it leaves vast bulk of memory to be predictably in order
> allocated. That ordering can be detected by a memory side-cache.
>
> The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> 10, 4MB this trades off randomization granularity for time spent
> shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
> allocator while still showing memory-side cache behavior improvements,
> and the expectation that the security implications of finer granularity
> randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.

Perhaps it would help some of the detractors of this feature to make
this a runtime choice? Some benchmarks show improvements, some show
regressions. It could just be up to the admin to turn this on/off
given their paranoia levels? (i.e. the shuffling could become a no-op
with a given specific boot param?)

-Kees

-- 
Kees Cook
Pixel Security
