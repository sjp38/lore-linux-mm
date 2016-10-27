Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8FA280258
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:15:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m83so14835755wmc.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:15:16 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id fk10si9676836wjb.155.2016.10.27.10.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 10:15:15 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id n67so60401687wme.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:15:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161025155106.29946-1-dsafonov@virtuozzo.com>
References: <20161025155106.29946-1-dsafonov@virtuozzo.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Thu, 27 Oct 2016 20:14:54 +0300
Message-ID: <CAJwJo6ZC=Z0RsjRgt8W1USuk0fp5_bJJHeQuKXHH50bBSNbd3g@mail.gmail.com>
Subject: Re: [PATCH 0/7] powerpc/mm: refactor vDSO mapping code
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: open list <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

2016-10-25 18:50 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
> Cleanup patches for vDSO on powerpc.
> Originally, I wanted to add vDSO remapping on arm/aarch64 and
> I decided to cleanup that part on powerpc.
> I've add a hook for vm_ops for vDSO just like I did for x86.
> Other changes - reduce exhaustive code duplication.
> No visible to userspace changes expected.
>
> Tested on qemu with buildroot rootfs.
>
> Dmitry Safonov (7):
>   powerpc/vdso: unify return paths in setup_additional_pages
>   powerpc/vdso: remove unused params in vdso_do_func_patch{32,64}
>   powerpc/vdso: separate common code in vdso_common
>   powerpc/vdso: introduce init_vdso{32,64}_pagelist
>   powerpc/vdso: split map_vdso from arch_setup_additional_pages
>   powerpc/vdso: switch from legacy_special_mapping_vmops
>   mm: kill arch_mremap

Ignore this version, please - I've just sent v3 with some new fixes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
