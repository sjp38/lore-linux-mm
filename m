Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4D58E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 22:41:45 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so15275380plt.7
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 19:41:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x6si33560042pgh.363.2018.12.26.19.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Dec 2018 19:41:43 -0800 (PST)
Date: Wed, 26 Dec 2018 19:41:41 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
Message-ID: <20181227034141.GD20878@bombadil.infradead.org>
References: <20181226131446.330864849@intel.com>
 <20181226133351.106676005@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181226133351.106676005@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Dec 26, 2018 at 09:14:47PM +0800, Fengguang Wu wrote:
> From: Fan Du <fan.du@intel.com>
> 
> This is a hack to enumerate PMEM as NUMA nodes.
> It's necessary for current BIOS that don't yet fill ACPI HMAT table.
> 
> WARNING: take care to backup. It is mutual exclusive with libnvdimm
> subsystem and can destroy ndctl managed namespaces.

Why depend on firmware to present this "correctly"?  It seems to me like
less effort all around to have ndctl label some namespaces as being for
this kind of use.
