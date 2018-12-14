Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB4B8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 12:32:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so3100549edc.6
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 09:32:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si46488edr.135.2018.12.14.09.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 09:32:02 -0800 (PST)
Date: Fri, 14 Dec 2018 18:31:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181214173159.GK5343@dhcp22.suse.cz>
References: <20181211132645.31053-1-mhocko@kernel.org>
 <201812150151.vUxN4ozA%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201812150151.vUxN4ozA%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Liu Bo <bo.liu@linux.alibaba.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat 15-12-18 01:13:53, kbuild test robot wrote:
> Hi Michal,
> 
> I love your patch! Yet something to improve:

Could you point the bot to v3 please? http://lkml.kernel.org/r/20181213092221.27270-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
