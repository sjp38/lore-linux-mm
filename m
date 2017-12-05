Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 21E2A6B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 19:34:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q186so12678431pga.23
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 16:34:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b16si11047887pff.393.2017.12.04.16.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 16:34:48 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: RFC: dev_pagemap reference counting
Date: Mon,  4 Dec 2017 16:34:41 -0800
Message-Id: <20171205003443.22111-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org

Hi Dan,

maybe I'm missing something, but it seems like we release the reference
to the previously found pgmap before passing it to get_dev_pagemap again.

Can you check if my findings make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
