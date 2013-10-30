Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1336A6B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 04:27:43 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so603550pab.38
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 01:27:42 -0700 (PDT)
Received: from psmtp.com ([74.125.245.115])
        by mx.google.com with SMTP id n5si1150626pav.243.2013.10.30.01.27.40
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 01:27:41 -0700 (PDT)
Date: Wed, 30 Oct 2013 17:28:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 13/15] slab: use struct page for slab management
Message-ID: <20131030082800.GA5753@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Hello, Pekka.

There are two problems with this patch.

One is that this makes kmemleak warning WHEN CONFIG_DEBUG_KMEMLEAK,
because of false kmemleak_scan_area() call.

Another is about non-existing 'struct freelist'. It is not really
matter, since I just use a pointer to struct freelist. Therefore,
my compiler doesn't complain anything and generated code works fine :(

Following patch fixes these problems.
If you want an incremental patch against original patchset,
I can do it. Please let me know what you want.

Thanks.

Changes from v2 to v2-FIX.
1. remove kmemleak_scan_area callsite, since it is useless now.
2. %s/'struct freelist *'/'void *'


-----------------------------8<-------------------------------
