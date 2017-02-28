Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 263E86B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:32:16 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 68so26685315itg.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:32:16 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id a189si3416711ite.108.2017.02.28.13.32.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:32:15 -0800 (PST)
Date: Tue, 28 Feb 2017 15:32:12 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
Message-ID: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

This has come up lots of times. We talked about this at linux.conf.au
again and agreed to try to make the radix tree movable. Sadly I have not
had enough time yet to make progress on this one but reliable higher order
allocations or some sort of other solution are needed for performance
reasons in many places. Recently there was demand from the developers in
the network stack and in the RDMA subsystems for large contiguous
allocation for performance reasons. I would like to talk about this (yes
the gazillionth time) to see what avenues there are to make progress on
this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
