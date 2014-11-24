Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 357E86B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 16:37:35 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id uq10so3932852igb.10
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:37:35 -0800 (PST)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id m69si4704803iom.69.2014.11.24.13.37.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 13:37:34 -0800 (PST)
Received: by mail-ie0-f172.google.com with SMTP id tr6so2105499ieb.3
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:37:33 -0800 (PST)
Date: Mon, 24 Nov 2014 13:37:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: fix confusing error messages in check_slab
In-Reply-To: <CAPAsAGxbA-3gi+vgoK2NtPM4UOeARw2+5xJtnp1kh8VzrfOHeg@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1411241336000.21237@chino.kir.corp.google.com>
References: <CAHkaATSEn9WMKJNRp5QvzPsno_vddtMXY39yvi=BGtb4M+Hqdw@mail.gmail.com> <alpine.DEB.2.11.1411241117030.8951@gentwo.org> <CAPAsAGxbA-3gi+vgoK2NtPM4UOeARw2+5xJtnp1kh8VzrfOHeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Min-Hua Chen <orca.chen@gmail.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 24 Nov 2014, Andrey Ryabinin wrote:

> It's in -mm already
> http://ozlabs.org/~akpm/mmotm/broken-out/mm-slub-fix-format-mismatches-in-slab_err-callers.patch
> 

Yeah, and the one in -mm isn't whitespace damaged.  Since the issue has 
existed for years, I don't think there's any rush in getting this in 3.18.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
