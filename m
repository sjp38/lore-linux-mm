Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 083706B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:42:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c5so1565518wmi.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:42:07 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id 130si1355546wml.115.2017.03.16.20.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 20:42:06 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id t189so6269031wmt.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:42:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-8-git-send-email-jglisse@redhat.com> <20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org>
 <d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com> <CAKTCnzmYob5uq11zkJE781BX9rDH9EYM7zxHH+ZMtTs4D5kkiQ@mail.gmail.com>
 <94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 17 Mar 2017 14:42:05 +1100
Message-ID: <CAKTCnznV1D4iZcn-PWvfu92_NB-Ree=cOT3bKfuJSPSXVB_QAg@mail.gmail.com>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use with
 device memory v4
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

>> Or make the HMM Kconfig feature 64BIT only by making it depend on 64BIT?
>>
>
> Yes, that was my first reaction too, but these particular routines are
> aspiring to be generic routines--in fact, you have had an influence there,
> because these might possibly help with NUMA migrations. :)
>

Yes, I still stick to them being generic, but I'd be OK if they worked
just for 64 bit systems.
Having said that even the 64 bit works version work for upto physical
sizes of 64 - PAGE_SHIFT
which is a little limiting I think.

One option is to make pfn's unsigned long long and do 32 and 64 bit computations
separately

Option 2, could be something like you said

a. Define a __weak migrate_vma to return -EINVAL
b. In a 64BIT only file define migrate_vma

Option 3

Something totally different

If we care to support 32 bit we go with 1, else option 2 is a good
starting point. There might
be other ways of doing option 2, like you've suggested

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
