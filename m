Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B63B0280422
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 10:32:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g50so1384426wra.4
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 07:32:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r142si449236wmg.229.2017.09.06.07.32.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 07:32:05 -0700 (PDT)
Date: Wed, 6 Sep 2017 16:32:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
Message-ID: <20170906143200.dq4or4paer7or5pc@dhcp22.suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
 <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
 <45813564-2342-fc8d-d31a-f4b68a724325@suse.cz>
 <20170906134908.xv7esjffv2xmpbq4@dhcp22.suse.cz>
 <ddbc40d6-0dba-d4d2-2c10-c6e2c3f9837a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddbc40d6-0dba-d4d2-2c10-c6e2c3f9837a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On Wed 06-09-17 15:55:22, Vlastimil Babka wrote:
> On 09/06/2017 03:49 PM, Michal Hocko wrote:
[...]
> > Yes this looks good to me. I am just wondering why we need 3 different
> > fake stacks. I do not see any code that would special case them when
> > dumping traces. Maybe this can be done on top?
> 
> It's so that the user can differentiate them in the output. That's why
> the functions are noinline.

Ble I've missed the the noinline part.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
