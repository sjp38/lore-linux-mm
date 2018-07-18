Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE24D6B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 22:56:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v9-v6so1548524pfn.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:56:56 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q68-v6si2404668pfl.317.2018.07.17.19.56.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 19:56:55 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2 0/7] swap: THP optimizing refactoring
References: <20180717005556.29758-1-ying.huang@intel.com>
	<20180717151715.rbxvofb6yf5toy47@ca-dmjordan1.us.oracle.com>
Date: Wed, 18 Jul 2018 10:56:52 +0800
In-Reply-To: <20180717151715.rbxvofb6yf5toy47@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 17 Jul 2018 08:17:16 -0700")
Message-ID: <87fu0hgsjv.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Tue, Jul 17, 2018 at 08:55:49AM +0800, Huang, Ying wrote:
>> This patchset is based on 2018-07-13 head of mmotm tree.
>
> Looks good.
>
> Still think patch 7 would be easier to review if split into two logical
> changes.  Either way, though.
>
> For the series,
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

Thanks a lot for your review!

Best Regards,
Huang, Ying
