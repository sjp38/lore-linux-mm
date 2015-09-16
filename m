Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8496B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 07:49:27 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so102077915lbp.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:49:26 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id ea18si17936848lbb.84.2015.09.16.04.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 04:49:25 -0700 (PDT)
Received: by lamp12 with SMTP id p12so125754061lam.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:49:24 -0700 (PDT)
Date: Wed, 16 Sep 2015 13:48:57 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 0/2] prepare zbud to be used by zram as underlying allocator
Message-Id: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org, akpm@linux-foundation.org, minchan@kernel.org, sergey.senozhatsky@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

as a follow-up to my previous patchset, I decided to first prepare
zbud/zpool related patches and then have some testing rounds and
performance measurements for zram running over both, and come up
with improved/verified zram/zpool patches then. So for now, here
comes the zbud/zpool part.

-- 
Vitaly Wool <vitalywool@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
