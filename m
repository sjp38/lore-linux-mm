Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C97FF6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 16:26:56 -0500 (EST)
Received: by pacej9 with SMTP id ej9so17120947pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 13:26:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id qk3si3480177pac.28.2015.12.01.13.26.55
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 13:26:56 -0800 (PST)
Date: Tue, 1 Dec 2015 23:26:36 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:3272!
Message-ID: <20151201212636.GA137439@black.fi.intel.com>
References: <565C5F2D.5060003@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565C5F2D.5060003@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Nov 30, 2015 at 09:37:33AM -0500, Sasha Levin wrote:
> Hi Kirill,
> 
> I've hit the following while fuzzing with trinity on the latest -next kernel:
> 
> [  321.348184] page:ffffea0011a20080 count:1 mapcount:1 mapping:ffff8802d745f601 index:0x1802
> [  321.350607] flags: 0x320035c00040078(uptodate|dirty|lru|active|swapbacked)
> [  321.453706] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> [  321.455353] page->mem_cgroup:ffff880286620000

I think this should help:
