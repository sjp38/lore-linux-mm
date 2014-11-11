Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3830C6B0130
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:57:47 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id r5so8051106qcx.33
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 10:57:47 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id w38si38189029qgw.25.2014.11.11.10.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 10:57:46 -0800 (PST)
Date: Tue, 11 Nov 2014 12:57:44 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC v1 0/6] introduce gcma
In-Reply-To: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Message-ID: <alpine.DEB.2.11.1411111255420.6657@gentwo.org>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: akpm@linux-foundation.org, lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org

On Wed, 12 Nov 2014, SeongJae Park wrote:

> Difference with cma is choice and operation of 2nd-class client. In gcma,
> 2nd-class client should allocate pages from the reserved area only if the
> allocated pages mets following conditions.

How about making CMA configurable in some fashion to be able to specify
the type of 2nd class clients? Clean page-cache pages can also be rather
easily evicted (see zone-reclaim). You could migrate them out when they
are dirtied so that you do not have the high writeback latency from the
CMA reserved area if it needs to be evicted later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
