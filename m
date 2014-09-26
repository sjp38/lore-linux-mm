Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1B76B0035
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 13:33:33 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so446514vcb.24
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:33:33 -0700 (PDT)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id ec1si2667521vdb.19.2014.09.26.10.33.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 10:33:32 -0700 (PDT)
Received: by mail-vc0-f178.google.com with SMTP id lf12so7381659vcb.9
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bTXPzYH+TMjM9-NyVajZms8zKdEMMLDPvOKvRSoD8tog@mail.gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
	<1411562649-28231-14-git-send-email-a.ryabinin@samsung.com>
	<CACT4Y+bTXPzYH+TMjM9-NyVajZms8zKdEMMLDPvOKvRSoD8tog@mail.gmail.com>
Date: Fri, 26 Sep 2014 21:33:32 +0400
Message-ID: <CAPAsAGzDWQ6LKN1RN6u0cv6eTVfxgRT6NCpGA08dC6dnDiUKmA@mail.gmail.com>
Subject: Re: [RFC PATCH v3 13/13] kasan: introduce inline instrumentation
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Marek <mmarek@suse.cz>

2014-09-26 21:18 GMT+04:00 Dmitry Vyukov <dvyukov@google.com>:
>
> Yikes!
> So this works during bootstrap, for user memory accesses, valloc
> memory, etc, right?
>

Yes, this works. Userspace memory access in instrumented code will
produce general protection fault,
so it won't be unnoticed.


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
