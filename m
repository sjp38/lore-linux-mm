Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0E06B0038
	for <linux-mm@kvack.org>; Sat,  7 Jan 2017 04:19:55 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so129688412wjb.7
        for <linux-mm@kvack.org>; Sat, 07 Jan 2017 01:19:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si2813666wrb.150.2017.01.07.01.19.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 07 Jan 2017 01:19:53 -0800 (PST)
Date: Sat, 7 Jan 2017 10:19:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] net: use kvmalloc rather than open coded variant
Message-ID: <20170107091949.GA5047@dhcp22.suse.cz>
References: <20170106161944.GW5556@dhcp22.suse.cz>
 <201701071152.Do5cZJAt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701071152.Do5cZJAt%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Eric Dumazet <edumazet@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 07-01-17 11:33:15, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on net-next/master]
> [also build test ERROR on v4.10-rc2 next-20170106]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/net-use-kvmalloc-rather-than-open-coded-variant/20170107-104105
> config: x86_64-randconfig-i0-201701 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: the linux-review/Michal-Hocko/net-use-kvmalloc-rather-than-open-coded-variant/20170107-104105 HEAD 29df6a817f53555953b47c6f8d09397f9f7b598c builds fine.
>       It only hurts bisectibility.

This patch depends on
http://lkml.kernel.org/r/20170102133700.1734-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
