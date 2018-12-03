Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7F56B6B9A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:22:49 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 4so11244817plc.5
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:22:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j1si14810192pff.42.2018.12.03.15.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:22:48 -0800 (PST)
Date: Mon, 3 Dec 2018 15:22:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] iomap: get/put the page in
 iomap_page_create/release()
Message-Id: <20181203152243.095e6b846fd9f623a339e4ab@linux-foundation.org>
In-Reply-To: <20181115184140.1388751-1-pjaroszynski@nvidia.com>
References: <20181115184140.1388751-1-pjaroszynski@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: p.jaroszynski@gmail.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Piotr Jaroszynski <pjaroszynski@nvidia.com>

On Thu, 15 Nov 2018 10:41:40 -0800 p.jaroszynski@gmail.com wrote:

> migrate_page_move_mapping() expects pages with private data set to have
> a page_count elevated by 1. This is what used to happen for xfs through
> the buffer_heads code before the switch to iomap in commit 82cb14175e7d
> ("xfs: add support for sub-pagesize writeback without buffer_heads").
> Not having the count elevated causes move_pages() to fail on memory
> mapped files coming from xfs.
> 
> Make iomap compatible with the migrate_page_move_mapping() assumption
> by elevating the page count as part of iomap_page_create() and lowering
> it in iomap_page_release().

What are the real-world end-user effects of this bug?

Is a -stable backport warranted?
