Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE776B025F
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 09:26:29 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 33so1095321pll.9
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 06:26:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 11si2049952plb.316.2017.12.06.06.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 06:26:27 -0800 (PST)
Date: Wed, 6 Dec 2017 06:26:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3] mm: Add unmap_mapping_pages
Message-ID: <20171206142627.GD32044@bombadil.infradead.org>
References: <20171205154453.GD28760@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205154453.GD28760@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

v3:
 - Fix compilation
   (I forgot to git commit --amend)
 - Added Ross' Reviewed-by
v2:
 - Fix inverted mask in dax.c
 - Pass 'false' instead of '0' for 'only_cows'
 - nommu definition

--- 8< ---
