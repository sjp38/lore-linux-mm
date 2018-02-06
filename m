Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 074BE6B0003
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 07:37:42 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v186so936910pfb.8
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 04:37:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g1si8571636pfj.237.2018.02.06.04.37.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Feb 2018 04:37:40 -0800 (PST)
Date: Tue, 6 Feb 2018 04:37:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
Message-ID: <20180206123735.GA6151@bombadil.infradead.org>
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130151446.24698-4-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Jan 30, 2018 at 05:14:43PM +0200, Igor Stoppa wrote:
> @@ -1744,6 +1748,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  			const void *caller)
>  {
>  	struct vm_struct *area;
> +	unsigned int page_counter;
>  	void *addr;
>  	unsigned long real_size = size;
>  
> @@ -1769,6 +1774,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  
>  	kmemleak_vmalloc(area, size, gfp_mask);
>  
> +	for (page_counter = 0; page_counter < area->nr_pages; page_counter++)
> +		area->pages[page_counter]->area = area;
> +
>  	return addr;
>  

LOCAL variable names should be short, and to the point.  If you have
some random integer loop counter, it should probably be called ``i``.
Calling it ``loop_counter`` is non-productive, if there is no chance of it
being mis-understood.  Similarly, ``tmp`` can be just about any type of
variable that is used to hold a temporary value.

(Documentation/process/coding-style.rst)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
