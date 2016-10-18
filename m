Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA5556B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:56:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 128so221629831pfz.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 23:56:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id sm3si28537694pac.261.2016.10.17.23.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 23:56:18 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [RFC] reduce latency in __purge_vmap_area_lazy
Date: Tue, 18 Oct 2016 08:56:05 +0200
Message-Id: <1476773771-11470-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

Hi all,

this is my spin at sorting out the long lock hold times in
__purge_vmap_area_lazy.  It is based on the patch from Joel sent this
week.  I don't have any good numbers for it, but it survived an
xfstests run on XFS which is a significant vmalloc user.  The
changelogs could still be improved as well, but I'd rather get it
out quickly for feedback and testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
