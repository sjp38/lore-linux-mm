Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 16F006B00CC
	for <linux-mm@kvack.org>; Tue, 19 May 2015 11:24:32 -0400 (EDT)
Received: by lagr1 with SMTP id r1so29551133lag.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:24:31 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id e5si5085219wix.88.2015.05.19.08.24.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 08:24:29 -0700 (PDT)
Received: by wgjc11 with SMTP id c11so22246098wgj.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:24:29 -0700 (PDT)
Date: Tue, 19 May 2015 17:27:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519152710.GK6203@dhcp22.suse.cz>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
 <20150519145340.GI6203@dhcp22.suse.cz>
 <20150519151302.GG2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519151302.GG2462@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue 19-05-15 16:13:02, Mel Gorman wrote:
[...]
>                :ffffffff811c160f:       je     ffffffff811c1630 <mem_cgroup_try_charge+0x40>
>                :ffffffff811c1611:       xor    %eax,%eax
>                :ffffffff811c1613:       xor    %ebx,%ebx
>      1 1.7e-05 :ffffffff811c1615:       mov    %rbx,(%r12)
>      7 1.2e-04 :ffffffff811c1619:       add    $0x10,%rsp
>   1211  0.0203 :ffffffff811c161d:       pop    %rbx
>      5 8.4e-05 :ffffffff811c161e:       pop    %r12
>      5 8.4e-05 :ffffffff811c1620:       pop    %r13
>   1249  0.0210 :ffffffff811c1622:       pop    %r14
>      7 1.2e-04 :ffffffff811c1624:       pop    %rbp
>      5 8.4e-05 :ffffffff811c1625:       retq   
>                :ffffffff811c1626:       nopw   %cs:0x0(%rax,%rax,1)
>    295  0.0050 :ffffffff811c1630:       mov    (%rdi),%rax
> 160703  2.6973 :ffffffff811c1633:       mov    %edx,%r13d

Huh, what? Even if this was off by one and the preceding instruction has
consumed the time. This would be reading from page->flags but the page
should be hot by the time we got here, no?

> #### MEL: I was surprised to see this atrocity. It's a PageSwapCache check
> #### /usr/src/linux-4.0-vanilla/./arch/x86/include/asm/bitops.h:311
> #### /usr/src/linux-4.0-vanilla/include/linux/page-flags.h:261
> #### /usr/src/linux-4.0-vanilla/mm/memcontrol.c:5473
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
