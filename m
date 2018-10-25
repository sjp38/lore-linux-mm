Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1A886B02AF
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 12:43:54 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id l7-v6so5923503plg.6
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:43:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t5-v6si7825993pgt.7.2018.10.25.09.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 09:43:53 -0700 (PDT)
Subject: Re: [PATCH 06/17] prmem: test cases for memory protection
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-7-igor.stoppa@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0175ca6a-40d1-0fde-350c-891488432ecb@intel.com>
Date: Thu, 25 Oct 2018 09:43:52 -0700
MIME-Version: 1.0
In-Reply-To: <20181023213504.28905-7-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> +static bool is_address_protected(void *p)
> +{
> +	struct page *page;
> +	struct vmap_area *area;
> +
> +	if (unlikely(!is_vmalloc_addr(p)))
> +		return false;
> +	page = vmalloc_to_page(p);
> +	if (unlikely(!page))
> +		return false;
> +	wmb(); /* Flush changes to the page table - is it needed? */

No.

The rest of this is just pretty verbose and seems to have been very
heavily copied and pasted.  I guess that's OK for test code, though.
