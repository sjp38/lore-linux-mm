Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFDC06B026F
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 02:34:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b5-v6so11150862pfi.5
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 23:34:07 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r29-v6si15468114pff.24.2018.07.08.23.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jul 2018 23:34:06 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 01/21] mm, THP, swap: Enable PMD swap operations for CONFIG_THP_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-2-ying.huang@intel.com>
	<CAA9_cmcwczyEb=+3F7HtDDqZA-3rdqgw=gkYipDtx5r+4Kd5Tw@mail.gmail.com>
	<87muv1kluq.fsf@yhuang-dev.intel.com>
	<CAPcyv4hxBwRx_XPt9MrDq6xgvFnCmQhJee_G3-k=c62vxYDv1A@mail.gmail.com>
Date: Mon, 09 Jul 2018 14:34:02 +0800
In-Reply-To: <CAPcyv4hxBwRx_XPt9MrDq6xgvFnCmQhJee_G3-k=c62vxYDv1A@mail.gmail.com>
	(Dan Williams's message of "Sun, 8 Jul 2018 23:08:24 -0700")
Message-ID: <87bmbglxyd.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

Dan Williams <dan.j.williams@intel.com> writes:

> On Sun, Jul 8, 2018 at 10:40 PM, Huang, Ying <ying.huang@intel.com> wrote:
>> Dan Williams <dan.j.williams@intel.com> writes:

>>> Would that also allow us to clean up the usage of
>>> CONFIG_ARCH_ENABLE_THP_MIGRATION in fs/proc/task_mmu.c? In other
>>> words, what's the point of having nice ifdef'd alternatives in header
>>> files when ifdefs are still showing up in C files, all of it should be
>>> optionally determined by header files.
>>
>> Unfortunately, I think it is not a easy task to wrap all C code via
>> #ifdef in header files.  And it may be over-engineering to wrap them
>> all.  I guess this is why there are still some #ifdef in C files.
>
> That's the entire point. Yes, over-engineer the header files so the
> actual C code is more readable.

Take pagemap_pmd_range() in fs/proc/task_mmu.c as an example, to avoid
#ifdef, we may wrap all code between #ifdef/#endif into a separate
function, put the new function into another C file (which is compiled
only if #ifdef is true), then change header files for that too.

In this way, we avoid #ifdef/#endif, but the code is more complex and
tightly related code may be put into different files.  The readability
may be hurt too.

Maybe you have smarter way to change the code to avoid #ifdef and
improve code readability?

Best Regards,
Huang, Ying
