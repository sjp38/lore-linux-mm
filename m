Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD9BB6B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 07:12:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x10-v6so14020676edx.9
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:12:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1-v6si8585361ejf.66.2018.10.16.04.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 04:12:31 -0700 (PDT)
Date: Tue, 16 Oct 2018 13:12:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4 1/3] mm: Shuffle initial free memory
Message-ID: <20181016111230.GR18839@dhcp22.suse.cz>
References: <153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153922180696.838512.12621709717839260874.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGXu5j+PStxYhiJaWM-mt4+WWbS_WAfvyHoyZYD5ndDLN2SY6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+PStxYhiJaWM-mt4+WWbS_WAfvyHoyZYD5ndDLN2SY6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 15-10-18 15:25:47, Kees Cook wrote:
> On Wed, Oct 10, 2018 at 6:36 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> > caches it leaves vast bulk of memory to be predictably in order
> > allocated. That ordering can be detected by a memory side-cache.
> >
> > The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> > pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> > 10, 4MB this trades off randomization granularity for time spent
> > shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
> > allocator while still showing memory-side cache behavior improvements,
> > and the expectation that the security implications of finer granularity
> > randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.
> 
> Perhaps it would help some of the detractors of this feature to make
> this a runtime choice? Some benchmarks show improvements, some show
> regressions. It could just be up to the admin to turn this on/off
> given their paranoia levels? (i.e. the shuffling could become a no-op
> with a given specific boot param?)

Sure, making this a opt-in is really necessary but it would be even
_better_ to actually evaluate how much security relevance it has as
well. If for nothing else then to allow an educated decision rather than
a fear driven one. And that pretty much involves evaluation on how hard
it is to bypass the randomness. If I am going to pay some overhead I
would like to know how much hardening I get in return, right? Something
completely missing in the current evaluation so far.
-- 
Michal Hocko
SUSE Labs
