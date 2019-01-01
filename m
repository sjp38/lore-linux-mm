Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A81BA8E0002
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:28:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r9so30188786pfb.13
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 19:28:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p4si13626206pli.432.2018.12.31.19.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Dec 2018 19:28:18 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x013OcVQ123356
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:28:17 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pqtnas7vk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 22:28:17 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 03:28:15 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH] mm: Introduce page_size()
In-Reply-To: <20181231134223.20765-1-willy@infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
Date: Tue, 01 Jan 2019 08:57:53 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87y385awg6.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Matthew Wilcox <willy@infradead.org> writes:


>  static inline unsigned hstate_index_to_shift(unsigned index)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363e..e920ef9927539 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -712,6 +712,12 @@ static inline void set_compound_order(struct page *page, unsigned int order)
>  	page[1].compound_order = order;
>  }
>  
> +/* Returns the number of bytes in this potentially compound page. */
> +static inline unsigned long page_size(struct page *page)
> +{
> +	return (unsigned long)PAGE_SIZE << compound_order(page);
> +}
> +


How about compound_page_size() to make it clear this is for
compound_pages? Should we make it work with Tail pages by doing
compound_head(page)?


-aneesh
