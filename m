Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62A846B000E
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:17:22 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id z1-v6so432676ual.15
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:17:22 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w63-v6si352318vkf.272.2018.07.17.08.17.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 08:17:21 -0700 (PDT)
Date: Tue, 17 Jul 2018 08:17:16 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH v2 0/7] swap: THP optimizing refactoring
Message-ID: <20180717151715.rbxvofb6yf5toy47@ca-dmjordan1.us.oracle.com>
References: <20180717005556.29758-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717005556.29758-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, Jul 17, 2018 at 08:55:49AM +0800, Huang, Ying wrote:
> This patchset is based on 2018-07-13 head of mmotm tree.

Looks good.

Still think patch 7 would be easier to review if split into two logical
changes.  Either way, though.

For the series,
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
