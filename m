Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7A408E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:06:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so6142490eda.3
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 06:06:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 18-v6si7374231ejw.229.2018.12.21.06.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 06:06:44 -0800 (PST)
Subject: Re: [PATCH] mm: Define VM_(MAX|MIN)_READAHEAD via sizes.h constants
References: <20181221125314.5177-1-nborisov@suse.com>
 <20181221132423.GA10600@bombadil.infradead.org>
From: Nikolay Borisov <nborisov@suse.com>
Message-ID: <8c5224ce-ba67-2afc-3864-051b8220a87a@suse.com>
Date: Fri, 21 Dec 2018 16:06:42 +0200
MIME-Version: 1.0
In-Reply-To: <20181221132423.GA10600@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org, linux-fsdevel@vger.kernel.org



On 21.12.18 г. 15:24 ч., Matthew Wilcox wrote:
> On Fri, Dec 21, 2018 at 02:53:14PM +0200, Nikolay Borisov wrote:
>> All users of the aformentioned macros convert them to kbytes by
>> multplying. Instead, directly define the macros via the aptly named
>> SZ_16K/SZ_128K ones. Also remove the now redundant comments explaining
>> that VM_* are defined in kbytes it's obvious. No functional changes.
> 
> Actually, all users of these constants convert them to pages!
> 
>> +	q->backing_dev_info->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
>> +		sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
>> +	sb->s_bdi->ra_pages	= VM_MAX_READAHEAD / PAGE_SIZE;
>> +	sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
>> +	sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
> 
>> -#define VM_MAX_READAHEAD	128	/* kbytes */
>> -#define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
>> +#define VM_MAX_READAHEAD	SZ_128K
>> +#define VM_MIN_READAHEAD	SZ_16K	/* includes current page */
> 
> So perhaps:
> 
> #define VM_MAX_READAHEAD	(SZ_128K / PAGE_SIZE)
> 
> VM_MIN_READAHEAD isn't used, so just delete it?

I thought about that but didn't know if people will complain that some
times in the future we might need it.

> 
