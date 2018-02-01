Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE5986B0006
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 19:00:39 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id k19so1321829ita.8
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 16:00:39 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id s13si388223ioa.193.2018.01.31.16.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 16:00:39 -0800 (PST)
Date: Wed, 31 Jan 2018 18:00:36 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
In-Reply-To: <20180130151446.24698-4-igor.stoppa@huawei.com>
Message-ID: <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
References: <20180130151446.24698-1-igor.stoppa@huawei.com> <20180130151446.24698-4-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, 30 Jan 2018, Igor Stoppa wrote:

> @@ -1769,6 +1774,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>
>  	kmemleak_vmalloc(area, size, gfp_mask);
>
> +	for (page_counter = 0; page_counter < area->nr_pages; page_counter++)
> +		area->pages[page_counter]->area = area;
> +
>  	return addr;

Well this introduces significant overhead for large sized allocation. Does
this not matter because the areas are small?

Would it not be better to use compound page allocations here?
page_head(whatever) gets you the head page where you can store all sorts
of information about the chunk of memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
