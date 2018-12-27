Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B253B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 15:32:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d41so23479473eda.12
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 12:32:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x53si837438eda.361.2018.12.27.12.32.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 12:32:01 -0800 (PST)
Date: Thu, 27 Dec 2018 21:31:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181227203158.GO16738@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181226131446.330864849@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed 26-12-18 21:14:46, Wu Fengguang wrote:
> This is an attempt to use NVDIMM/PMEM as volatile NUMA memory that's
> transparent to normal applications and virtual machines.
> 
> The code is still in active development. It's provided for early design review.

So can we get a high level description of the design and expected
usecases please?
-- 
Michal Hocko
SUSE Labs
