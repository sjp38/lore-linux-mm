Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48B8E6B026D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:45:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so336728edr.4
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:45:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4-v6si1573726edl.365.2018.07.23.04.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 04:45:21 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
Date: Mon, 23 Jul 2018 13:45:18 +0200
MIME-Version: 1.0
In-Reply-To: <20180720123422.10127-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 07/20/2018 02:34 PM, David Hildenbrand wrote:
> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
> So reserved pages might be access by dump tools although nobody except
> the owner should touch them.

Are you sure about that? Or maybe I understand wrong. Maybe it changed
recently, but IIRC pages that are backing memmap (struct pages) are also
PG_reserved. And you definitely do want those in the dump.

> This is relevant in virtual environments where we soon might want to
> report certain reserved pages to the hypervisor and they might no longer
> be accessible - what already was documented for reserved pages a long
> time ago ("might not even exist").
> 
> David Hildenbrand (2):
>   mm: clarify semantics of reserved pages
>   kdump: include PG_reserved value in VMCOREINFO
> 
>  include/linux/page-flags.h | 4 ++--
>  kernel/crash_core.c        | 1 +
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
