Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAEF6B0491
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:16:19 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id z14-v6so1295212lfh.13
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:16:19 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d25-v6sor6710075ljg.13.2018.10.29.11.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:16:17 -0700 (PDT)
Subject: Re: [PATCH 06/17] prmem: test cases for memory protection
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-7-igor.stoppa@huawei.com>
 <0175ca6a-40d1-0fde-350c-891488432ecb@intel.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <1ef1168c-0c44-274a-5942-257b84609051@gmail.com>
Date: Mon, 29 Oct 2018 20:16:14 +0200
MIME-Version: 1.0
In-Reply-To: <0175ca6a-40d1-0fde-350c-891488432ecb@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 25/10/2018 17:43, Dave Hansen wrote:
>> +static bool is_address_protected(void *p)
>> +{
>> +	struct page *page;
>> +	struct vmap_area *area;
>> +
>> +	if (unlikely(!is_vmalloc_addr(p)))
>> +		return false;
>> +	page = vmalloc_to_page(p);
>> +	if (unlikely(!page))
>> +		return false;
>> +	wmb(); /* Flush changes to the page table - is it needed? */
> 
> No.

ok

> The rest of this is just pretty verbose and seems to have been very
> heavily copied and pasted.  I guess that's OK for test code, though.

I was tempted to play with macros, as templates to generate tests on the 
fly, according to the type being passed.

But I was afraid it might generate an even stronger rejection than the 
rest of the patchset already has.

Would it be acceptable/preferable?

--
igor
