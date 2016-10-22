Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 767106B0069
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:17:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r16so79704977pfg.4
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 08:17:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ga9si6132228pac.23.2016.10.22.08.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 08:17:27 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: reduce latency in __purge_vmap_area_lazy
Date: Sat, 22 Oct 2016 17:17:13 +0200
Message-Id: <1477149440-12478-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

Hi all,

this is my spin at sorting out the long lock hold times in
__purge_vmap_area_lazy.  It is based on the patch from Joel sent this
week.  I don't have any good numbers for it, but it survived an
xfstests run on XFS which is a significant vmalloc user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
