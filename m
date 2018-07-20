Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF2A66B026B
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:34:35 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d18-v6so8386829qtj.20
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:34:35 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s20-v6si1751362qvj.130.2018.07.20.05.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 05:34:35 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
Date: Fri, 20 Jul 2018 14:34:20 +0200
Message-Id: <20180720123422.10127-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

Dumping tools (like makedumpfile) right now don't exclude reserved pages.
So reserved pages might be access by dump tools although nobody except
the owner should touch them.

This is relevant in virtual environments where we soon might want to
report certain reserved pages to the hypervisor and they might no longer
be accessible - what already was documented for reserved pages a long
time ago ("might not even exist").

David Hildenbrand (2):
  mm: clarify semantics of reserved pages
  kdump: include PG_reserved value in VMCOREINFO

 include/linux/page-flags.h | 4 ++--
 kernel/crash_core.c        | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

-- 
2.17.1
