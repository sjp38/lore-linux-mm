Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F41C96B0253
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 22:14:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i88so175867607pfk.3
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 19:14:45 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id m17si13989739pgh.314.2016.12.17.19.14.44
        for <linux-mm@kvack.org>;
        Sat, 17 Dec 2016 19:14:45 -0800 (PST)
Date: Sat, 17 Dec 2016 22:14:42 -0500 (EST)
Message-Id: <20161217.221442.430708127662119954.davem@davemloft.net>
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context
 register 1
From: David Miller <davem@davemloft.net>
In-Reply-To: <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
	<1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Fri, 16 Dec 2016 10:35:27 -0800

> In current code, only context ID register 0 is set and used by the MMU.
> On sun4v platforms that support MMU shared context, there is an additional
> context ID register: specifically context register 1.  When searching
> the TLB, the MMU will find a match if the virtual address matches and
> the ID contained in context register 0 -OR- context register 1 matches.
> 
> Load the shared context ID into context ID register 1.  Care must be
> taken to load register 1 after register 0, as loading register 0
> overwrites both register 0 and 1.  Modify code loading register 0 to
> also load register one if applicable.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

You can't make these register accesses if the feature isn't being
used.

Considering the percentage of applications which will actually use
this thing, incuring the overhead of even loading the shared context
register is simply unacceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
