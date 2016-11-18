Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAA36B040F
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:06 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so141741287pfy.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id e17si8207191pgh.24.2016.11.18.05.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:05 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: reduce latency in __purge_vmap_area_lazy V2
Date: Fri, 18 Nov 2016 14:03:46 +0100
Message-Id: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hi all,

this is my spin at sorting out the long lock hold times in
__purge_vmap_area_lazy.  It is based on a patch from Joel.

Changes since V1:
 - add vfree_atomic, thanks to Andrey Ryabinin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
