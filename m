Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5F5D6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 18:54:55 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g187so11434254wmg.2
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 15:54:55 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d1si2783403wrb.217.2018.01.29.15.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jan 2018 15:54:51 -0800 (PST)
Subject: Re: [PATCH] mm/swap.c: fix kernel-doc functions and parameters
References: <bac38b63-5b67-b2b7-8fe9-ff9c36f59ded@infradead.org>
 <20180129051532.GA18247@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9e3a965a-eceb-a9c2-9277-68231077c146@infradead.org>
Date: Mon, 29 Jan 2018 15:54:39 -0800
MIME-Version: 1.0
In-Reply-To: <20180129051532.GA18247@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On 01/28/2018 09:15 PM, Matthew Wilcox wrote:
> On Sun, Jan 28, 2018 at 08:01:08PM -0800, Randy Dunlap wrote:
>> @@ -400,6 +400,10 @@ void mark_page_accessed(struct page *pag
>>  }
>>  EXPORT_SYMBOL(mark_page_accessed);
>>  
>> +/**
>> + * __lru_cache_add: add a page to the page lists
>> + * @page: the page to add
>> + */
>>  static void __lru_cache_add(struct page *page)
>>  {
>>  	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
>> @@ -410,10 +414,6 @@ static void __lru_cache_add(struct page
>>  	put_cpu_var(lru_add_pvec);
>>  }
>>  
>> -/**
>> - * lru_cache_add: add a page to the page lists
>> - * @page: the page to add
>> - */
>>  void lru_cache_add_anon(struct page *page)
>>  {
>>  	if (PageActive(page))
> 
> I don't see the point in adding kernel-doc for a static function while
> deleting it for a non-static function?  I'd change the name of the
> function in the second hunk and drop the first hunk.

Agree.

> Also, the comment doesn't actually fit the kernel-doc format (colon
> versus hyphen; missing capitalisation and full-stop).

I certainly missed the colon vs. hyphen.  But I am not aware of any kernel-doc
format about capitalization or ending with a period -- and don't like them either.
Those descriptions usually are not complete sentences unless they are longer
descriptions.

>> @@ -913,11 +913,11 @@ EXPORT_SYMBOL(__pagevec_lru_add);
>>   * @pvec:	Where the resulting entries are placed
>>   * @mapping:	The address_space to search
>>   * @start:	The starting entry index
>> - * @nr_entries:	The maximum number of entries
>> + * @nr_pages:	The maximum number of entries
>>   * @indices:	The cache indices corresponding to the entries in @pvec
>>   *
>>   * pagevec_lookup_entries() will search for and return a group of up
>> - * to @nr_entries pages and shadow entries in the mapping.  All
>> + * to @nr_pages pages and shadow entries in the mapping.  All
>>   * entries are placed in @pvec.  pagevec_lookup_entries() takes a
>>   * reference against actual pages in @pvec.
>>   *
> 
> I think the documentation has the right name here; it is the number of
> entries and not the number of pages which is returned.  We should change
> the code to match the documentation here ;-)

OK, will change that and send v2.

Thanks for the comments.
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
