Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A67B58E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:31:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22-v6so10463414plq.21
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:31:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f2-v6si18134304pgh.661.2018.09.10.13.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 13:31:14 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
 <cc817bc8-bced-fb07-cb2d-c122463380a7@intel.com>
 <20180824150717.GA10093@WeideMacBook-Pro.local>
 <20180903222732.v52zdya2c2hkff7n@master>
 <20180909013807.6ux4cidt3nehofz5@master>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5140697b-540a-1db1-e300-af1aaece97ad@intel.com>
Date: Mon, 10 Sep 2018 13:30:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180909013807.6ux4cidt3nehofz5@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 09/08/2018 06:38 PM, owner-linux-mm@kvack.org wrote:
> 
> At last, here is the test result on my 4G virtual machine. I added printk
> before and after sparse_memory_present_with_active_regions() and tested three
> times with/without "likely".
> 
>                without      with
>     Elapsed   0.000252     0.000250   -0.8%
> 
> The benefit seems to be too small on a 4G virtual machine or even this is not
> stable. Not sure we can see some visible effect on a 32G machine.

I think it's highly unlikely you have found something significant here.
It's one system, in a VM and it's not being measured using a mechanism
that is suitable for benchmarking (the kernel dmesg timestamps).

Plus, if this is a really tight loop, the cpu's branch predictors will
be good at it.
