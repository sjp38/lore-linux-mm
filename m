Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 861876B04D6
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 04:56:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q1so667021pgv.4
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 01:56:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d76si2094523pfk.321.2018.01.04.01.56.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 01:56:10 -0800 (PST)
Date: Thu, 4 Jan 2018 09:56:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [aaron:for_lkp_skl_2sp2_test 151/225]
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c:1188:34: error:
 '__GFP_COLD' undeclared; did you mean '__GFP_COMP'?
Message-ID: <20180104095607.57f64ngwbfwm2jx2@suse.de>
References: <201801041745.WvR1n84H%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201801041745.WvR1n84H%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Aaron Lu <aaron.lu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Jan 04, 2018 at 05:25:47PM +0800, kbuild test robot wrote:
> tree:   aaron/for_lkp_skl_2sp2_test
> head:   6c9381b65892222cbe2214fb22af9043f9ce1065
> commit: cebd3951aaa6936a2dd70e925a5d5667b896da23 [151/225] mm: remove __GFP_COLD
> config: x86_64-randconfig-x009-201800 (attached as .config)
> compiler: gcc-7 (Debian 7.2.0-12) 7.2.1 20171025
> reproduce:
>         git checkout cebd3951aaa6936a2dd70e925a5d5667b896da23
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 

This looks like a backport of some description. __GFP_COLD is removed in
all cases in mainline so I'm guessing this is specific to Aaron's tree.
The fix is to eliminate __GFP_COLD and just use GFP_KERNEL.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
