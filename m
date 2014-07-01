Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9076B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:13:53 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so8823936iec.19
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:13:53 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id dw1si31795224icb.23.2014.07.01.15.13.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 15:13:52 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id at20so1206542iec.18
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:13:51 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:13:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm,hugetlb: simplify error handling in
 hugetlb_cow()
In-Reply-To: <1404246097-18810-2-git-send-email-davidlohr@hp.com>
Message-ID: <alpine.DEB.2.02.1407011513180.4004@chino.kir.corp.google.com>
References: <1404246097-18810-1-git-send-email-davidlohr@hp.com> <1404246097-18810-2-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, aswin@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 1 Jul 2014, Davidlohr Bueso wrote:

> When returning from hugetlb_cow(), we always (1) put back the refcount
> for each referenced page -- always 'old', and 'new' if allocation was
> successful. And (2) retake the page table lock right before returning,
> as the callers expects. This logic can be simplified and encapsulated,
> as proposed in this patch. In addition to cleaner code, we also shave
> a few bytes off in instruction text:
> 
>    text    data     bss     dec     hex filename
>   28399     462   41328   70189   1122d mm/hugetlb.o-baseline
>   28367     462   41328   70157   1120d mm/hugetlb.o-patched
> 
> Passes libhugetlbfs testcases.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

Not sure the extra indirection is clearer code, but I can't argue with the 
difference in object size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
