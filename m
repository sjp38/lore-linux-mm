Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF5D16B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:44:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b79so772221pfk.9
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 00:44:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a67si5074033pgc.227.2017.10.17.00.44.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 00:44:51 -0700 (PDT)
Date: Tue, 17 Oct 2017 09:44:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <20171017074448.qupoajpjbcfdpz5z@dhcp22.suse.cz>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com>
 <1507656303-103845-4-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710161709460.140151@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Yang Shi <yang.s@alibaba-inc.com>, cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-10-17 17:15:31, David Rientjes wrote:
> Please simply dump statistics for all slab caches where the memory 
> footprint is greater than 5% of system memory.

Unconditionally? User controlable?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
