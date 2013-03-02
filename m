Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 67C056B0005
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 22:35:42 -0500 (EST)
Received: by mail-oa0-f43.google.com with SMTP id l10so6818215oag.30
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 19:35:41 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 2 Mar 2013 11:35:41 +0800
Message-ID: <CAJd=RBD53ZkXb9bBV9gcBVF2+3dOVVFu41FCE9Ey++nSmpL9yQ@mail.gmail.com>
Subject: Re: [PATCH -V1 15/24] mm/THP: HPAGE_SHIFT is not a #define on some arch
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hello Aneesh

[with lkml cced]

>-#if HPAGE_PMD_ORDER > MAX_ORDER
>-#error "hugepages can't be allocated by the buddy allocator"
>-#endif
...
>-	if (!has_transparent_hugepage()) {
>+	if (!has_transparent_hugepage() || (HPAGE_PMD_ORDER > MAX_ORDER)) {
> 		transparent_hugepage_flags = 0;
> 		return -EINVAL;
> 	}

Fair for other archs that support THP, if you are changing
build error to runtime error?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
