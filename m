Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57FF36B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 06:20:37 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id f7so215601036vkb.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 03:20:37 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id 22si1210132qtq.132.2016.07.11.03.20.35
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 03:20:36 -0700 (PDT)
Message-ID: <5783710E.3070602@huawei.com>
Date: Mon, 11 Jul 2016 18:12:30 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: a question about protection_map[]
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

We can use mprotect to set read only or read/write.

mprotect_fixup()
	vma_set_page_prot()
		vm_pgprot_modify()
			vm_get_page_prot()
				protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]

The following code shows that prots from __P001(PROT_READ) and __P010(PROT_WRITE)
are the same, so how does it distinguish read only or read/write from mprotect?

pgprot_t protection_map[16] = {
	__P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,
	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
};

#define __P001	PAGE_READONLY
#define __P010	PAGE_COPY

#define PAGE_READONLY		__pgprot(_PAGE_PRESENT | _PAGE_USER |	\
					 _PAGE_ACCESSED | _PAGE_NX)

#define PAGE_COPY_NOEXEC	__pgprot(_PAGE_PRESENT | _PAGE_USER |	\
					 _PAGE_ACCESSED | _PAGE_NX)
#define PAGE_COPY		PAGE_COPY_NOEXEC


Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
