Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 310B76B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 09:38:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b23so135968pfc.22
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 06:38:09 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m9si25606786pln.274.2017.04.26.06.38.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 06:38:08 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 0/1] mm: Improve consistency of ___GFP_xxx masks
Date: Wed, 26 Apr 2017 16:35:48 +0300
Message-ID: <20170426133549.22603-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, namhyung@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

The GFP bitmasks and the __GFP_BITS_SHIFT defines are expressed as
hardcoded constants.
This can be expressed in a more consistent way by relying on an enum of
shift positions.

Igor Stoppa (1):
  Remove hardcoding of ___GFP_xxx bitmasks

 include/linux/gfp.h | 82 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 55 insertions(+), 27 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
