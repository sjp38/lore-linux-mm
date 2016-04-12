Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6FE6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:02:25 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id j35so11196359qge.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:02:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x67si7581987qhe.81.2016.04.12.03.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:02:24 -0700 (PDT)
Date: Tue, 12 Apr 2016 12:02:15 +0200
From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: [LSF/MM TOPIC] Ideas for SLUB allocator
Message-ID: <20160412120215.000283c7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, js1304@gmail.com
Cc: lsf-pc@lists.linux-foundation.org

Hi Rik,

I have another topic, which is very MM-specific.

I have some ideas for improving SLUB allocator further, after my work
on implementing the slab bulk APIs.  Maybe you can give me a small
slot, I only have 7 guidance slides.  Or else I hope we/I can talk
about these ideas in a hallway track with Christoph and others involved
in slab development...

I've already published the preliminary slides here:
 http://people.netfilter.org/hawk/presentations/MM-summit2016/slab_mm_summit2016.odp

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
