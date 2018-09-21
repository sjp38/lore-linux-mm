Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98AD08E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:41:23 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id x5-v6so24435620ioa.6
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:41:23 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id p65-v6si18126892iop.187.2018.09.21.12.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Sep 2018 12:41:22 -0700 (PDT)
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
 <20180920222415.19464.38400.stgit@localhost.localdomain>
 <a40a78c0-207b-03b7-344c-847b12a4f896@microsoft.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <4d984974-ff16-35e4-76ff-f5e43e5e90da@deltatee.com>
Date: Fri, 21 Sep 2018 13:41:12 -0600
MIME-Version: 1.0
In-Reply-To: <a40a78c0-207b-03b7-344c-847b12a4f896@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v4 1/5] mm: Provide kernel parameter to allow disabling
 page init poisoning
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On 2018-09-21 1:04 PM, Pasha Tatashin wrote:
> 
>> +			pr_err("vm_debug option '%c' unknown. skipped\n",
>> +			       *str);
>> +		}
>> +
>> +		str++;
>> +	}
>> +out:
>> +	if (page_init_poisoning && !__page_init_poisoning)
>> +		pr_warn("Page struct poisoning disabled by kernel command line option 'vm_debug'\n");
> 
> New lines '\n' can be removed, they are not needed for kprintfs.

No, that's not correct.

A printk without a newline termination is not emitted
as output until the next printk call. (To support KERN_CONT).
Therefore removing the '\n' causes a printk to not be printed when it is
called which can cause long delayed messages and subtle problems when
debugging. Always keep the newline in place even though the kernel will
add one for you if it's missing.

Logan
