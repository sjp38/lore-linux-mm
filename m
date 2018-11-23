Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 245036B2FFB
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:47:38 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id a62so5067048oii.23
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 23:47:38 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u19si25082612otc.201.2018.11.22.23.47.36
        for <linux-mm@kvack.org>;
        Thu, 22 Nov 2018 23:47:36 -0800 (PST)
Subject: Re: [PATCH] mm: debug: Fix a width vs precision bug in printk
References: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6f7469d9-d589-7a6b-b157-fe481e396fff@arm.com>
Date: Fri, 23 Nov 2018 13:17:33 +0530
MIME-Version: 1.0
In-Reply-To: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org



On 11/23/2018 12:51 PM, Dan Carpenter wrote:
> We had intended to only print dentry->d_name.len characters but there is
> a width vs precision typo so if the name isn't NUL terminated it will
> read past the end of the buffer.
> 
> Fixes: 408ddbc22be3 ("mm: print more information about mapping in __dump_page")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
