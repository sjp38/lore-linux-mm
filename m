Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05A478E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 16:27:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a18-v6so6321152pgn.10
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:27:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h90-v6si3394626plb.64.2018.09.25.13.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 13:27:43 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <13285e05-fb90-b948-6f96-777f94079657@intel.com>
Date: Tue, 25 Sep 2018 13:26:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180925201921.3576.84239.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/25/2018 01:20 PM, Alexander Duyck wrote:
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

Can we have vm_debug=off for turning things off, please?  That seems to
be pretty standard.

Also, we need to document the defaults.  I think the default is "all
debug options are enabled", but it would be nice to document that.
