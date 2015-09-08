Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id EC1F36B0254
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 19:23:32 -0400 (EDT)
Received: by igxx6 with SMTP id x6so1899491igx.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 16:23:32 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id 5si8061507pdz.127.2015.09.08.16.23.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 16:23:32 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so137044778pac.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 16:23:32 -0700 (PDT)
Date: Tue, 8 Sep 2015 16:23:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer
 in get_unmapped_area()
In-Reply-To: <COL130-W16C972B0457D5C7C9CB06B9560@phx.gbl>
Message-ID: <alpine.DEB.2.10.1509081623180.26116@chino.kir.corp.google.com>
References: <COL130-W16C972B0457D5C7C9CB06B9560@phx.gbl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On Sat, 5 Sep 2015, Chen Gang wrote:

> 
> From a1bf4726f71d6d0394b41309944646fc806a8a0c Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sat, 5 Sep 2015 21:51:08 +0800
> Subject: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer in
> get_unmapped_area()
> 
> Call the function pointer directly, then let code a bit simpler.
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
