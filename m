Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 183A382F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 09:32:40 -0400 (EDT)
Received: by oifu63 with SMTP id u63so77312030oif.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 06:32:39 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id o3si24360976obv.60.2015.10.27.06.32.39
        for <linux-mm@kvack.org>;
        Tue, 27 Oct 2015 06:32:39 -0700 (PDT)
Date: Tue, 27 Oct 2015 06:49:16 -0700 (PDT)
Message-Id: <20151027.064916.312540587298733586.davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
From: David Miller <davem@davemloft.net>
In-Reply-To: <20151027122647.GG9891@dhcp22.suse.cz>
References: <20151023.065957.1690815054807881760.davem@davemloft.net>
	<20151026165619.GB2214@cmpxchg.org>
	<20151027122647.GG9891@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 27 Oct 2015 13:26:47 +0100

> On Mon 26-10-15 12:56:19, Johannes Weiner wrote:
> [...]
>> Or any other combination of pick-and-choose consumers. But
>> honestly, nowadays all our paths are lockless, and the counting is an
>> atomic-add-return with a per-cpu batch cache.
> 
> You are still hooking into hot paths and there are users who want to
> squeeze every single cycle from the HW.

Yeah, you're basically probably undoing a half year of work by another
developer who was able to remove an atomic from these paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
