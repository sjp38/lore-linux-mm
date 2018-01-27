Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC806B025E
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 04:37:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c22so2104054pfj.2
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 01:37:27 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id a14-v6si612479plt.216.2018.01.27.01.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Jan 2018 01:37:25 -0800 (PST)
From: "Skidanov, Alexey" <alexey.skidanov@intel.com>
Subject: CMA allocation failure
Date: Sat, 27 Jan 2018 09:37:20 +0000
Message-ID: <040863540BC4D141BEB17753235088284DBB1DDA@hasmsx108.ger.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

I enabled CMA global area to be 8GB. Immediately after boot, I'm able to al=
locate the really big contiguous chunks of memory (about 8GB). But several =
minutes after the boot, there is some degradation in an ability of CMA to a=
llocate contiguous memory buffers:

[ 2333.037004] cma: cma_alloc(): memory range at ffffea000f0a0000 is busy, =
retrying
[ 2333.037005] cma: cma_alloc: alloc failed, req-size: 500000 pages, ret: -=
16
[ 2333.037006] cma: number of available pages: 6@122+9@151+9@183+2096848@30=
4=3D> 2096872 free of 2097152 total pages
[ 2333.037034] cma: cma_alloc(): returned (null)

The request to allocate 500000 pages (~2GB) is failed while the block of 20=
96848 contiguous pages are available.

One of the failure reasons is the user allocated pinned pages in the middle=
 of the CMA reserved range. Can I somehow verify it? Can I get the details =
of such pinned pages (number of pages, source of pinning, etc. ... )?

Thanks,
Alexey
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
