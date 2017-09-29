Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA4D06B0038
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 17:45:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k54so536927qtf.14
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 14:45:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w123si4424826qkc.74.2017.09.29.14.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 14:45:44 -0700 (PDT)
Subject: Re: [PATCH 12/15] mm: Add variant of pagevec_lookup_range_tag()
 taking number of pages
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-13-jack@suse.cz>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <91bd5e36-3f73-c770-9555-bff47f74f49a@oracle.com>
Date: Fri, 29 Sep 2017 17:45:33 -0400
MIME-Version: 1.0
In-Reply-To: <20170927160334.29513-13-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 09/27/2017 12:03 PM, Jan Kara wrote:
> +unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
> +		struct address_space *mapping, pgoff_t *index, pgoff_t end,
> +		int tag, unsigned max_pages)
> +{
> +	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
> +		min_t(unsigned int, max_pages, PAGEVEC_SIZE), pvec->pages);
> +	return pagevec_count(pvec);
> +}
> +EXPORT_SYMBOL(pagevec_lookup_range_tag);

The EXPORT_SYMBOL should be pagevec_lookup_range_nr_tag instead of 
pagevec_lookup_range_tag.

Daniel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
