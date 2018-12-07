Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 179E76B7EEC
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 01:20:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h11so2465363pfj.13
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 22:20:37 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id g7si2073243plq.336.2018.12.06.22.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 22:20:36 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V8 00/21] swap: Swapout/swapin THP in one piece
References: <20181207054122.27822-1-ying.huang@intel.com>
Date: Fri, 07 Dec 2018 14:20:32 +0800
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com> (Huang Ying's
	message of "Fri, 7 Dec 2018 13:41:00 +0800")
Message-ID: <871s6tluxb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Huang Ying <ying.huang@intel.com> writes:

> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
>
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [02/21], [03/21], [04/21],
> [05/21], [06/21], [07/21], [08/21], [09/21], [10/21], [11/21],
> [12/21], [20/21], [21/21].
>
> Hi, Andrea and Kirill, could you help me to review the THP part of the
> patchset?  Especially [01/21], [07/21], [09/21], [11/21], [13/21],
> [15/21], [16/21], [17/21], [18/21], [19/21], [20/21].
>
> Hi, Johannes and Michal, could you help me to review the cgroup part
> of the patchset?  Especially [14/21].
>
> And for all, Any comment is welcome!
>
> This patchset is based on the 2018-11-29 head of mmotm/master.

Sorry, just after sending this patchset out, I found there is a new
version of mmotm/master (2018-12-04), and the swapoff() implementation
is changed much.  I will rebase this patchset on the new version,
especially the swapoff() support.

So, please ignore this patchset, I will send out a new version soon.
Sorry again for bothering.

Best Regards,
Huang, Ying
