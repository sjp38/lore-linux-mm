Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5776B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:55:36 -0500 (EST)
Received: by ykfs79 with SMTP id s79so113939297ykf.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:55:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v5si10924483ywb.119.2015.11.12.12.55.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 12:55:35 -0800 (PST)
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 200EB8F506
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 20:55:35 +0000 (UTC)
Date: Thu, 12 Nov 2015 21:55:31 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Memory exhaustion testing?
Message-ID: <20151112215531.69ccec19@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: brouer@redhat.com

Hi MM-people,

How do you/we test the error paths when the system runs out of memory?

What kind of tools do you use?
or Any tricks to provoke this?

For testing my recent change to the SLUB allocator, I've implemented a
crude kernel module that tries to allocate all memory, so I can test the
error code-path in kmem_cache_alloc_bulk.

see:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test04_exhaust_mem.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
