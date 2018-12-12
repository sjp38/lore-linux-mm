Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5180A8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 10:57:23 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so8656140edd.11
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 07:57:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si1615067edi.431.2018.12.12.07.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 07:57:22 -0800 (PST)
Date: Wed, 12 Dec 2018 16:57:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181212155715.GU1286@dhcp22.suse.cz>
References: <20181211132645.31053-1-mhocko@kernel.org>
 <201812122333.JV0874ol%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201812122333.JV0874ol%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Liu Bo <bo.liu@linux.alibaba.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed 12-12-18 23:33:10, kbuild test robot wrote:
> Hi Michal,
> 
> I love your patch! Yet something to improve:

Well, I hate it ;) (like all obviously broken patches) Sorry this is a
typo. v2 sent out

Thanks!
-- 
Michal Hocko
SUSE Labs
