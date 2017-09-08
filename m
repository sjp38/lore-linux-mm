Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA4586B032D
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 03:42:19 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 11so3807162pge.4
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 00:42:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m7si1268137plt.732.2017.09.08.00.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 00:42:17 -0700 (PDT)
Date: Fri, 8 Sep 2017 00:42:16 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 01/11] mm: add MAP_HUGETLB support to vm_mmap
Message-ID: <20170908074216.GA4957@infradead.org>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-2-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907173609.22696-2-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Thu, Sep 07, 2017 at 11:35:59AM -0600, Tycho Andersen wrote:
> vm_mmap is exported, which means kernel modules can use it. In particular,
> for testing XPFO support, we want to use it with the MAP_HUGETLB flag, so
> let's support it via vm_mmap.

>  	} else if (flags & MAP_HUGETLB) {
> +		file = map_hugetlb_setup(&len, flags);
>  		if (IS_ERR(file))
>  			return PTR_ERR(file);
>  	}

It seems like you should remove this hunk entirely and make all
MAP_HUGETLB calls go through vm_mmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
