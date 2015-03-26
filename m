Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3CA6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:58:25 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so579228igb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:58:24 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id k83si5207808iod.47.2015.03.26.11.58.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 11:58:24 -0700 (PDT)
Received: by ignm3 with SMTP id m3so18875555ign.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:58:24 -0700 (PDT)
Date: Thu, 26 Mar 2015 11:58:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] thp: handle errors in hugepage_init() properly
In-Reply-To: <1427385160-74036-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1503261157210.8238@chino.kir.corp.google.com>
References: <1427385160-74036-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 26 Mar 2015, Kirill A. Shutemov wrote:

> We miss error-handling in few cases hugepage_init(). Let's fix that.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

For completeness, it would probably make sense to suppress the 
set_recommended_min_free_kbytes() in start_khugepaged() when the kthread 
can't properly be created as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
