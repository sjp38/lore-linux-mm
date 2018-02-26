Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 548C56B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:38:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m22so8662458pfg.15
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:38:12 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id k62si5679594pgc.388.2018.02.26.08.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 08:38:11 -0800 (PST)
Subject: Re: [PATCH 3/7] struct page: add field for vm_struct
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-4-igor.stoppa@huawei.com>
 <20180225033808.GB15796@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <5ec5d25a-dbf2-5be4-b449-3704254f8117@huawei.com>
Date: Mon, 26 Feb 2018 18:37:36 +0200
MIME-Version: 1.0
In-Reply-To: <20180225033808.GB15796@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 25/02/18 05:38, Matthew Wilcox wrote:
> On Fri, Feb 23, 2018 at 04:48:03PM +0200, Igor Stoppa wrote:
>> @@ -1769,6 +1771,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>  
>>  	kmemleak_vmalloc(area, size, gfp_mask);
>>  
>> +	for (i = 0; i < area->nr_pages; i++)
>> +		area->pages[i]->area = area;
>> +
>>  	return addr;
>>  
>>  fail:
> 
> IMO, this is the wrong place to initialise the page->area.  It should be
> done in __vmalloc_area_node() like so:
> 
>                         area->nr_pages = i;
>                         goto fail;
>                 }
> +		page->area = area;
>                 area->pages[i] = page;
>                 if (gfpflags_allow_blocking(gfp_mask))
>                         cond_resched();
> 


ok

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
