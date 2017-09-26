Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 092716B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:56:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 97so11743390wrb.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 00:56:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 128si1118338wmn.161.2017.09.26.00.56.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 00:56:40 -0700 (PDT)
Date: Tue, 26 Sep 2017 09:56:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2 v4] oom: capture unreclaimable slab info in oom
 message when kernel panic
Message-ID: <20170926075638.l7xoaismqsnp4qsw@dhcp22.suse.cz>
References: <1505947132-4363-1-git-send-email-yang.s@alibaba-inc.com>
 <20170925142352.havlx6ikheanqyhj@dhcp22.suse.cz>
 <e773cd57-8df6-ee6e-d051-857b8f354a0a@alibaba-inc.com>
 <20170925203235.vhhiqxp72v67n76l@dhcp22.suse.cz>
 <2a50d51e-1a36-aa44-3ee6-cb78ac9c7715@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a50d51e-1a36-aa44-3ee6-cb78ac9c7715@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 26-09-17 05:52:50, Yang Shi wrote:
> Maybe we can set a unreclaimable slab/total mem ratio. For example, when
> unreclaimable slab size >= 50% total memory size, then we print out slab
> stats in oom? And, the ratio might be adjustable in /proc.

This sounds quite reasonable to me. I would compare the slab amount to
the directly user backed memory (LRU ages) though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
