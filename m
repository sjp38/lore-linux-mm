Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA49A8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:31:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so2778054eda.12
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:31:34 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r1-v6si1201476eje.70.2019.01.09.03.31.33
        for <linux-mm@kvack.org>;
        Wed, 09 Jan 2019 03:31:33 -0800 (PST)
Date: Wed, 9 Jan 2019 11:31:26 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] selinux: avc: mark avc node as not a leak
Message-ID: <20190109113126.nzpmb7xx4xqtn37w@mbp>
References: <1547023162-6381-1-git-send-email-prpatel@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547023162-6381-1-git-send-email-prpatel@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prateek Patel <prpatel@nvidia.com>
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, eparis@parisplace.org, linux-kernel@vger.kernel.org, selinux@vger.kernel.org, linux-tegra@vger.kernel.org, talho@nvidia.com, swarren@nvidia.com, linux-mm@kvack.org, snikam@nvidia.com, vdumpa@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>

Hi Prateek,

On Wed, Jan 09, 2019 at 02:09:22PM +0530, Prateek Patel wrote:
> From: Sri Krishna chowdary <schowdary@nvidia.com>
> 
> kmemleak detects allocated objects as leaks if not accessed for
> default scan time. The memory allocated using avc_alloc_node
> is freed using rcu mechanism when nodes are reclaimed or on
> avc_flush. So, there is no real leak here and kmemleak_scan
> detects it as a leak which is false positive. Hence, mark it as
> kmemleak_not_leak.

In theory, kmemleak should detect the node->rhead in the lists used by
call_rcu() and not report it as a leak. Which RCU options do you have
enabled (just to check whether kmemleak tracks the RCU internal lists)?

Also, does this leak eventually disappear without your patch? Does

  echo dump=0xffffffc0dd1a0e60 > /sys/kernel/debug/kmemleak

still display this object?

Thanks.

-- 
Catalin
