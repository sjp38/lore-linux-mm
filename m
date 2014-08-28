Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 58DD36B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 11:50:17 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id s18so1165529lam.6
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:50:16 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id mu10si6119637lbb.7.2014.08.28.08.50.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 08:50:15 -0700 (PDT)
Received: by mail-lb0-f177.google.com with SMTP id z11so1119422lbi.8
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:50:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140827135348.9c9ccefebccc74083f7ba922@linux-foundation.org>
References: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
	<20140827135348.9c9ccefebccc74083f7ba922@linux-foundation.org>
Date: Fri, 29 Aug 2014 00:50:14 +0900
Message-ID: <CAC5umygnUybkmut9NogAxRD14kQp-NAq5=m14QRVng8pYEAhHg@mail.gmail.com>
Subject: Re: [PATCH 1/2] x86: use memblock_alloc_range() or memblock_alloc_base()
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org

2014-08-28 5:53 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> On Sun, 24 Aug 2014 23:56:02 +0900 Akinobu Mita <akinobu.mita@gmail.com> wrote:
>
>> Replace memblock_find_in_range() and memblock_reserve() with
>> memblock_alloc_range() or memblock_alloc_base().
>
> Please spend a little more time preparing the changelogs?

OK, I'll be careful next time.

> Why are we making this change?  Because memblock_alloc_range() is
> equivalent to memblock_find_in_range()+memblock_reserve() and it's just
> a cleanup?  Or is there some deeper functional reason?

This is just a cleanup and I thought there are no functional change.
But I've just realized that the conversion to memblock_alloc_base() in
this patch changes the behaviour in the error case.
Because memblock_alloc_base calls panic if it can't allocate.

So please drop this patch from -mm tree for now.

> Does memblock_find_in_range() need to exist?  Can we convert all
> callers to memblock_alloc_range()?

There are two callsites where we can't simply convert with
memblock_alloc_range (arch/s390/kernel/setup.c, arch/x86/mm/init.c).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
