Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 06BDB6B006C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:38:14 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so193859ier.0
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:38:13 -0800 (PST)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id c20si4533189igo.46.2014.12.17.16.38.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 16:38:13 -0800 (PST)
Received: by mail-ie0-f178.google.com with SMTP id tp5so165696ieb.37
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:38:12 -0800 (PST)
Date: Wed, 17 Dec 2014 16:38:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] hugetlb, sysctl: pass '.extra1 = NULL' rather then
 '.extra1 = &zero'
In-Reply-To: <1418826650-10145-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1412171636400.23841@chino.kir.corp.google.com>
References: <548CA6B6.3060901@colorfullife.com> <1418826650-10145-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: akpm@linux-foundation.org, Dmitry Vyukov <dvyukov@google.com>, Manfred Spraul <manfred@colorfullife.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "nadia.derbey@bull.net" <Nadia.Derbey@bull.net>, aquini@redhat.com, Joe Perches <joe@perches.com>, avagin@openvz.org, LKML <linux-kernel@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <andreyknvl@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, kasan-dev <kasan-dev@googlegroups.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org

On Wed, 17 Dec 2014, Andrey Ryabinin wrote:

> Commit ed4d4902ebdd ("mm, hugetlb: remove hugetlb_zero and hugetlb_infinity") replaced
> 'unsigned long hugetlb_zero' with 'int zero' leading to out-of-bounds access
> in proc_doulongvec_minmax().
> Use '.extra1 = NULL' instead of '.extra1 = &zero'. Passing NULL is equivalent to
> passing minimal value, which is 0 for unsigned types.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Suggested-by: Manfred Spraul <manfred@colorfullife.com>
> Fixes: ed4d4902ebdd ("mm, hugetlb: remove hugetlb_zero and hugetlb_infinity")
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Acked-by: David Rientjes <rientjes@google.com>

Patch title is a little awkward, though, maybe "mm, hugetlb: remove 
unnecessary lower bound on sysctl handlers"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
