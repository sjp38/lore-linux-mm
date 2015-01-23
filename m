Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6B96B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 16:37:38 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so8415760qcx.11
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 13:37:37 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id k4si3633294qaz.40.2015.01.23.13.37.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 13:37:36 -0800 (PST)
Message-Id: <20150123213727.142554068@linux.com>
Date: Fri, 23 Jan 2015 15:37:27 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 0/3] Slab allocator array operations
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

Attached a series of 3 patches to implement functionality to allocate
arrays of pointers to slab objects. This can be used by the slab
allocators to offer more optimized allocation and free paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
