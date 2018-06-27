Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42E1D6B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 13:48:08 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s24-v6so2178519iob.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:48:08 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m4-v6si1015569iof.200.2018.06.27.10.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 10:48:07 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5RHdB0u074861
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:48:06 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2jum0a5vd1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:48:05 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5RHm5ou003229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:48:05 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5RHm5t2032282
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:48:05 GMT
Received: by mail-ot0-f181.google.com with SMTP id k3-v6so3113251otl.12
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:48:04 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com>
In-Reply-To: <20180627013116.12411-1-bhe@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 27 Jun 2018 13:47:28 -0400
Message-ID: <CAGM2reYKn80fn8Nb_AT4ybVih4c7cd8+U1nDfJ-C0fwM+DB4jw@mail.gmail.com>
Subject: Re: [PATCH v5 0/4] mm/sparse: Optimize memmap allocation during sparse_init()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

This work made me think why do we even have
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER ? This really should be the
default behavior for all systems. Yet, it is enabled only on x86_64.
We could clean up an already messy sparse.c if we removed this config,
and enabled its path for all arches. We would not break anything
because if we cannot allocate one large mmap_map we still fallback to
allocating a page at a time the same as what happens when
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=n.

Pavel
