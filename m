Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACBE06B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 11:04:49 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j4so2240947wrg.15
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 08:04:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si1966925edb.141.2017.11.29.08.04.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 08:04:48 -0800 (PST)
Date: Wed, 29 Nov 2017 17:04:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-ID: <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
 <20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JianKang Chen <chenjiankang1@huawei.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Mon 27-11-17 12:33:41, Michal Hocko wrote:
> On Mon 27-11-17 19:09:24, JianKang Chen wrote:
> > From: Jiankang Chen <chenjiankang1@huawei.com>
> > 
> > __get_free_pages will return an virtual address, 
> > but it is not just 32-bit address, for example a 64-bit system. 
> > And this comment really confuse new bigenner of mm.
> 
> s@bigenner@beginner@
> 
> Anyway, do we really need a bug on for this? Has this actually caught
> any wrong usage? VM_BUG_ON tends to be enabled these days AFAIK and
> panicking the kernel seems like an over-reaction. If there is a real
> risk then why don't we simply mask __GFP_HIGHMEM off when calling
> alloc_pages?

I meant this
---
