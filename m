Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A15A66B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 18:47:09 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so131363359pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 15:47:09 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id z5si40989418par.231.2015.09.21.15.47.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 15:47:08 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so128644447pad.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 15:47:08 -0700 (PDT)
Date: Mon, 21 Sep 2015 15:47:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] doc: add information about max_ptes_swap
In-Reply-To: <1442525698-22598-1-git-send-email-ebru.akagunduz@gmail.com>
Message-ID: <alpine.DEB.2.10.1509211546480.27715@chino.kir.corp.google.com>
References: <1442525698-22598-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, akpm@linux-foundation.org, oleg@redhat.com, kirill.shutemov@linux.intel.com, dave@stgolabs.net, denc716@gmail.com, ldufour@linux.vnet.ibm.com, sasha.levin@oracle.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org

On Fri, 18 Sep 2015, Ebru Akagunduz wrote:

> max_ptes_swap specifies how many pages can be brought in from
> swap when collapsing a group of pages into a transparent huge page.
> 
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
> 
> A higher value can cause excessive swap IO and waste
> memory. A lower value can prevent THPs from being
> collapsed, resulting fewer pages being collapsed into
> THPs, and lower memory access performance.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
