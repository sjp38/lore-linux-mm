Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 733076B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:09:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g92-v6so12354973plg.6
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:09:43 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50094.outbound.protection.outlook.com. [40.107.5.94])
        by mx.google.com with ESMTPS id q11-v6si13147915pgc.669.2018.05.22.09.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 09:09:42 -0700 (PDT)
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
Date: Tue, 22 May 2018 19:10:52 +0300
MIME-Version: 1.0
In-Reply-To: <20180518194519.3820-18-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>



On 05/18/2018 10:45 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> For diagnosing various performance and memory-leak problems, it is helpful
> to be able to distinguish pages which are in use as VMalloc pages.
> Unfortunately, we cannot use the page_type field in struct page, as
> this is in use for mapcount by some drivers which map vmalloced pages
> to userspace.
> 
> Use a special page->mapping value to distinguish VMalloc pages from
> other kinds of pages.  Also record a pointer to the vm_struct and the
> offset within the area in struct page to help reconstruct exactly what
> this page is being used for.
> 


This seems useless. page->vm_area and page->vm_offset are never used.
There are no follow up patches which use this new information 'For diagnosing various performance and memory-leak problems',
and no explanation how is it can be used in current form.

Also, this patch breaks code like this:
	if (mapping = page_mapping(page))
		// access mapping
