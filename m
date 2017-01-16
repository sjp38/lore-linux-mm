Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E05C6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:54:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so6700468wjb.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 00:54:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l143si11740362wmg.74.2017.01.16.00.54.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 00:54:07 -0800 (PST)
Date: Mon, 16 Jan 2017 09:54:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] net_sched: use kvmalloc rather than opencoded variant
Message-ID: <20170116085403.GB13641@dhcp22.suse.cz>
References: <20170106160743.GU5556@dhcp22.suse.cz>
 <201701150720.coxUa02H%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701150720.coxUa02H%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Eric Dumazet <edumazet@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun 15-01-17 07:43:01, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on net-next/master]
> [also build test ERROR on v4.10-rc3 next-20170113]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/net_sched-use-kvmalloc-rather-than-opencoded-variant/20170107-120926

This depends on kvmalloc patch. But I have rebased this patch on top of
others in
http://lkml.kernel.org/r/20170112153717.28943-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
