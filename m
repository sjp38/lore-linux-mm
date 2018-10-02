Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 539CE6B0006
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:49:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 17-v6so63864pgs.18
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:49:41 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t2-v6si15089710pge.64.2018.10.02.08.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:49:39 -0700 (PDT)
Subject: Re: [PATCHv3 6/6] mm/gup: Cache dev_pagemap while pinning pages
References: <20180921223956.3485-1-keith.busch@intel.com>
 <20180921223956.3485-7-keith.busch@intel.com>
 <20181002112623.zlxtcclhtslfx3pa@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5bb265e9-bc23-799a-ad01-30edbc762996@intel.com>
Date: Tue, 2 Oct 2018 08:49:39 -0700
MIME-Version: 1.0
In-Reply-To: <20181002112623.zlxtcclhtslfx3pa@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On 10/02/2018 04:26 AM, Kirill A. Shutemov wrote:
>> +	page = follow_page_mask(vma, address, foll_flags, &ctx);
>> +	if (ctx.pgmap)
>> +		put_dev_pagemap(ctx.pgmap);
>> +	return page;
>>  }
> Do we still want to keep the function as inline? I don't think so.
> Let's move it into mm/gup.c and make struct follow_page_context private to
> the file.

Yeah, and let's have a put_follow_page_context() that does the
put_dev_pagemap() rather than spreading that if() to each call site.
