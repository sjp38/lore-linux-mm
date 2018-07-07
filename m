Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 818F26B0006
	for <linux-mm@kvack.org>; Sat,  7 Jul 2018 17:13:00 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s24-v6so12814365iob.5
        for <linux-mm@kvack.org>; Sat, 07 Jul 2018 14:13:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d5-v6sor634406iok.167.2018.07.07.14.12.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Jul 2018 14:12:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180622035151.6676-1-ying.huang@intel.com> <20180622035151.6676-3-ying.huang@intel.com>
In-Reply-To: <20180622035151.6676-3-ying.huang@intel.com>
From: Dan Williams <dan.j.williams@gmail.com>
Date: Sat, 7 Jul 2018 14:12:48 -0700
Message-ID: <CAA9_cmc2b97TCRAKz-r4Zhb9mq_hsr41Xwe1zQkyhsLUc5LWPg@mail.gmail.com>
Subject: Re: [PATCH -mm -v4 02/21] mm, THP, swap: Make CONFIG_THP_SWAP depends
 on CONFIG_SWAP
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ying.huang@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, hughd@google.com, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, n-horiguchi@ah.jp.nec.com, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

On Thu, Jun 21, 2018 at 8:55 PM Huang, Ying <ying.huang@intel.com> wrote:
>
> From: Huang Ying <ying.huang@intel.com>
>
> It's unreasonable to optimize swapping for THP without basic swapping
> support.  And this will cause build errors when THP_SWAP functions are
> defined in swapfile.c and called elsewhere.
>
> The comments are fixed too to reflect the latest progress.

Looks good to me:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
