Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F12E6B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 03:33:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu12so12049529pac.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 00:33:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id d8si32118857pfd.256.2016.09.14.00.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 00:33:42 -0700 (PDT)
Date: Wed, 14 Sep 2016 00:33:40 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH v2 3/3] block: Always use a bounce buffer when XPFO
 is enabled
Message-ID: <20160914073340.GA28090@infradead.org>
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-4-juerg.haefliger@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914071901.8127-4-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu

On Wed, Sep 14, 2016 at 09:19:01AM +0200, Juerg Haefliger wrote:
> This is a temporary hack to prevent the use of bio_map_user_iov()
> which causes XPFO page faults.
> 
> Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>

Sorry, but if your scheme doesn't support get_user_pages access to
user memory is't a steaming pile of crap and entirely unacceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
