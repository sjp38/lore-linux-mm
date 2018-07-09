Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E48156B0271
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 02:34:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u16-v6so11145500pfm.15
        for <linux-mm@kvack.org>; Sun, 08 Jul 2018 23:34:39 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id v4-v6si13372353plo.208.2018.07.08.23.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jul 2018 23:34:39 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 02/21] mm, THP, swap: Make CONFIG_THP_SWAP depends on CONFIG_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-3-ying.huang@intel.com>
	<CAA9_cmc2b97TCRAKz-r4Zhb9mq_hsr41Xwe1zQkyhsLUc5LWPg@mail.gmail.com>
Date: Mon, 09 Jul 2018 14:34:35 +0800
In-Reply-To: <CAA9_cmc2b97TCRAKz-r4Zhb9mq_hsr41Xwe1zQkyhsLUc5LWPg@mail.gmail.com>
	(Dan Williams's message of "Sat, 7 Jul 2018 14:12:48 -0700")
Message-ID: <877em4lxxg.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, hughd@google.com, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, n-horiguchi@ah.jp.nec.com, zi.yan@cs.rutgers.edu, daniel.m.jordan@oracle.com

Dan Williams <dan.j.williams@gmail.com> writes:

> On Thu, Jun 21, 2018 at 8:55 PM Huang, Ying <ying.huang@intel.com> wrote:
>>
>> From: Huang Ying <ying.huang@intel.com>
>>
>> It's unreasonable to optimize swapping for THP without basic swapping
>> support.  And this will cause build errors when THP_SWAP functions are
>> defined in swapfile.c and called elsewhere.
>>
>> The comments are fixed too to reflect the latest progress.
>
> Looks good to me:
>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>

Thanks!

Best Regards,
Huang, Ying
