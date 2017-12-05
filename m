Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6FC66B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 10:44:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f7so438632pfa.21
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 07:44:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o30si260269pli.8.2017.12.05.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 07:44:54 -0800 (PST)
Date: Tue, 5 Dec 2017 07:44:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2] mm: Add unmap_mapping_pages
Message-ID: <20171205154453.GD28760@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org

v2:
 - Fix inverted mask in dax.c
 - Pass 'false' instead of '0' for 'only_cows'
 - nommu definition
