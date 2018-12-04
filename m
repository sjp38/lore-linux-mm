Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5E66B6C56
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 21:30:46 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id az10so11493254plb.11
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 18:30:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i69si14333993pgc.538.2018.12.03.18.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 18:30:44 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V7 RESEND 08/21] swap: Support to read a huge swap cluster for swapin a THP
References: <20181120085449.5542-1-ying.huang@intel.com>
	<20181120085449.5542-9-ying.huang@intel.com>
	<20181130233201.6yuzbhymtjddvf3u@ca-dmjordan1.us.oracle.com>
	<8736rirsox.fsf@yhuang-dev.intel.com>
	<20181203161538.gxleg2ugdj2woadr@ca-dmjordan1.us.oracle.com>
Date: Tue, 04 Dec 2018 10:30:41 +0800
In-Reply-To: <20181203161538.gxleg2ugdj2woadr@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Mon, 3 Dec 2018 08:15:38 -0800")
Message-ID: <87bm62aur2.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Sat, Dec 01, 2018 at 08:34:06AM +0800, Huang, Ying wrote:
>> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
>> > What do you think?
>> 
>> I think that swapoff() which is the main user of try_to_unuse() isn't a
>> common operation in practical.  So it's not necessary to make it more
>> complex for this.
>
> Ok, probably not worth the surgery on try_to_unuse, even if swapoff can be
> expensive when it does happen.
>
>> In alloc_hugepage_direct_gfpmask(), the only information provided by vma
>> is: vma->flags & VM_HUGEPAGE.  Because we have no vma available, I think
>> it is OK to just assume that the flag is cleared.  That is, rely on
>> system-wide THP settings only.
>> 
>> What do you think about this proposal?
>
> Sounds like a good compromise.
>
> So alloc_hugepage_direct_gfpmask will learn to make 'vma' optional?  Slightly
> concerned that future callers that should be passing vma's might not and open a
> way to ignore vma huge page hints, but probably not a big deal in practice.  

alloc_pages_vma() -> get_vma_policy() -> __get_vma_policy()

has done that already.  So I guess that's not a big issue.  The callers
should be careful.

Best Regards,
Huang, Ying
