Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE896B025E
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:17:49 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id 186so62604306yby.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:17:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m21si3652018ybf.35.2017.01.13.05.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 05:17:48 -0800 (PST)
Date: Fri, 13 Jan 2017 14:17:44 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [LSF/MM ATTEND] 2017 Optimizing page allocator and page_pool
Message-ID: <20170113141744.113fdd44@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>
Cc: brouer@redhat.com, Mel Gorman <mgorman@techsingularity.net>

Hello,

I'd like to attend this year LSF/MM summit.

I think it would be valuable for Mel and I to have some face-to-face
time, discussing ideas for optimizing the page allocator and the
generic page_pool idea.

I would like to give a short presentation/time-slot titled:
 "Memory vs. Networking: Provoking and fixing memory bottlenecks"

This is about framing the mind-bugling performance requirements
from 100Gbit/s networking.  Describing the bottlenecks I've hit,
with networking related to memory, and discussing ideas how to address
these bottlenecks.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
