Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B2B5B6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 13:48:39 -0500 (EST)
Received: by wmec201 with SMTP id c201so47839500wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:48:39 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id xt8si20122754wjb.197.2015.11.12.10.48.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 10:48:38 -0800 (PST)
Received: by wmww144 with SMTP id w144so213255653wmw.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:48:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447346238-29153-1-git-send-email-jmarchan@redhat.com>
References: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
	<1447346238-29153-1-git-send-email-jmarchan@redhat.com>
Date: Thu, 12 Nov 2015 21:48:38 +0300
Message-ID: <CAPAsAGwExjJzBvDo-LSF1u8wJMCa-0BALxKZ2Se_cxUs8r+29g@mail.gmail.com>
Subject: Re: [PATCH V2] mm: vmalloc: don't remove inexistent guard hole in remove_vm_area()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

2015-11-12 19:37 GMT+03:00 Jerome Marchand <jmarchan@redhat.com>:
> Commit 71394fe50146 ("mm: vmalloc: add flag preventing guard hole
> allocation") missed a spot. Currently remove_vm_area() decreases
> vm->size to "remove" the guard hole page, even when it isn't present.
> All but one users just free the vm_struct rigth away and never access
> vm->size anyway.
> Don't touch the size in remove_vm_area() and have __vunmap() use the
> proper get_vm_area_size() helper.
>
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
