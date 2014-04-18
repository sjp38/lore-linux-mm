Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 961526B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:51:31 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so1535687qab.4
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 06:51:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v10si11873869qat.162.2014.04.18.06.51.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 06:51:26 -0700 (PDT)
Date: Fri, 18 Apr 2014 06:51:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm/swap: cleanup *lru_cache_add* functions
Message-ID: <20140418135114.GA4911@infradead.org>
References: <1397826591-19379-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397826591-19379-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, minchan@kernel.org, shli@kernel.org, riel@redhat.com, sjenning@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mgorman@suse.de, aquini@redhat.com, aarcange@redhat.com, khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 18, 2014 at 09:09:51PM +0800, Jianyu Zhan wrote:
> In mm/swap.c, __lru_cache_add() is exported, but actually there are
> no users outside this file. However, lru_cache_add() is supposed to
> be used by vfs, or whatever others, but it is not exported.

There are no modular users of lru_cache_add, so please don't needlessly
export it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
