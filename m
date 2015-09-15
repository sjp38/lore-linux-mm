Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB7A6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 19:32:51 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so79638188qkc.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:32:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 100si19361379qgg.31.2015.09.15.16.32.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 16:32:50 -0700 (PDT)
Date: Tue, 15 Sep 2015 16:32:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5 v2] mm/memblock: Introduce
 memblock_first_region_size() helper
Message-Id: <20150915163248.d7a5e3fdb4e4dfa344731624@linux-foundation.org>
In-Reply-To: <1441117631-30589-1-git-send-email-kuleshovmail@gmail.com>
References: <1441117527-30466-1-git-send-email-kuleshovmail@gmail.com>
	<1441117631-30589-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  1 Sep 2015 20:27:11 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> Some architectures (like s390, microblaze and etc...) require size
> of the first memory region. This patch provides new memblock_first_region_size()
> helper for this case.
> 
> ...
>
> +phys_addr_t __init_memblock memblock_first_region_size(void)
> +{
> +	return memblock.memory.regions[0].size;
> +}
> +

Some callers call this from __init code, which is OK.

Other callers call it from an inlined function and I'm too lazy to work
out if all the callers of those callers are calling
memblock_first_region_size() from a compatible section.

So please either a) demonstrate that all the sectioning is correct (and
maintainable!) or b) simply inline memblock_first_region_size()...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
