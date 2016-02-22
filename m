Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id A92526B025E
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:19:15 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id gc3so177648888obb.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 14:19:15 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id h8si14093029oej.49.2016.02.22.14.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 14:19:14 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id w5so65514025oie.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 14:19:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456178322-1728962-1-git-send-email-arnd@arndb.de>
References: <1456178322-1728962-1-git-send-email-arnd@arndb.de>
Date: Mon, 22 Feb 2016 14:19:14 -0800
Message-ID: <CAPcyv4j-ByA7u0jnnLHeiEYNZU78-twRzQUoeo2BkmtODCAGHg@mail.gmail.com>
Subject: Re: [PATCH] nvdimm: use 'u64' for pfn flags
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Stuart Foster <smf.linux@ntlworld.com>, Julian Margetson <runaway@candw.ms>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Feb 22, 2016 at 1:58 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> A recent bugfix changed pfn_t to always be 64-bit wide, but did not
> change the code in pmem.c, which is now broken on 32-bit architectures
> as reported by gcc:
>
> In file included from ../drivers/nvdimm/pmem.c:28:0:
> drivers/nvdimm/pmem.c: In function 'pmem_alloc':
> include/linux/pfn_t.h:15:17: error: large integer implicitly truncated to unsigned type [-Werror=overflow]
>  #define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
>
> This changes the intermediate pfn_flags in struct pmem_device to
> be 64 bit wide as well, so they can store the flags correctly.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: db78c22230d0 ("mm: fix pfn_t vs highmem")

Thanks Arnd, I'll roll this up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
