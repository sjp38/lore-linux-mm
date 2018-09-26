Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4941D8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 03:38:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b17-v6so4337557pfo.20
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 00:38:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6-v6si4838675pls.150.2018.09.26.00.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 00:38:37 -0700 (PDT)
Date: Wed, 26 Sep 2018 09:38:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
Message-ID: <20180926073831.GC6278@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925201921.3576.84239.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Tue 25-09-18 13:20:12, Alexander Duyck wrote:
[...]
> +	vm_debug[=options]	[KNL] Available with CONFIG_DEBUG_VM=y.
> +			May slow down system boot speed, especially when
> +			enabled on systems with a large amount of memory.
> +			All options are enabled by default, and this
> +			interface is meant to allow for selectively
> +			enabling or disabling specific virtual memory
> +			debugging features.
> +
> +			Available options are:
> +			  P	Enable page structure init time poisoning
> +			  -	Disable all of the above options

I agree with Dave that this is confusing as hell. So what does vm_debug
(without any options means). I assume it's NOP and all debugging is
enabled and that is the default. What if I want to disable _only_ the
page struct poisoning. The weird lookcing `-' will disable all other
options that we might gather in the future.

Why cannot you simply go with [no]vm_page_poison[=on/off]?
-- 
Michal Hocko
SUSE Labs
