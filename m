Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0666B038A
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:50:36 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so5942703wme.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:50:36 -0700 (PDT)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id k62si1127574wmb.93.2017.03.15.09.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 09:50:35 -0700 (PDT)
Received: by mail-wr0-x229.google.com with SMTP id l37so15075275wrc.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:50:35 -0700 (PDT)
From: Avi Kivity <avi@scylladb.com>
Subject: MAP_POPULATE vs. MADV_HUGEPAGES
Message-ID: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
Date: Wed, 15 Mar 2017 18:50:32 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

A user is trying to allocate 1TB of anonymous memory in parallel on 48 
cores (4 NUMA nodes).  The kernel ends up spinning in 
isolate_freepages_block().


I thought to help it along by using MAP_POPULATE, but then my 
MADV_HUGEPAGE won't be seen until after mmap() completes, with pages 
already populated.  Are MAP_POPULATE and MADV_HUGEPAGE mutually exclusive?


Is my only option to serialize those memory allocations, and fault in 
those pages manually?  Or perhaps use mlock()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
