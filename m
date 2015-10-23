Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 879A26B0253
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:43:33 -0400 (EDT)
Received: by ioll68 with SMTP id l68so125107626iol.3
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:43:33 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id p6si3419354igj.14.2015.10.23.06.43.33
        for <linux-mm@kvack.org>;
        Fri, 23 Oct 2015 06:43:33 -0700 (PDT)
Date: Fri, 23 Oct 2015 06:59:57 -0700 (PDT)
Message-Id: <20151023.065957.1690815054807881760.davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151023131956.GA15375@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
	<1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
	<20151023131956.GA15375@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 23 Oct 2015 15:19:56 +0200

> On Thu 22-10-15 00:21:33, Johannes Weiner wrote:
>> Socket memory can be a significant share of overall memory consumed by
>> common workloads. In order to provide reasonable resource isolation
>> out-of-the-box in the unified hierarchy, this type of memory needs to
>> be accounted and tracked per default in the memory controller.
> 
> What about users who do not want to pay an additional overhead for the
> accounting? How can they disable it?

Yeah, this really cannot pass.

This extra overhead will be seen by %99.9999 of users, since entities
(especially distributions) just flip on all of these config options by
default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
