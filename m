Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 540C96B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 21:50:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z13so1842269pfe.21
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 18:50:32 -0700 (PDT)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id g12-v6si2311013plt.294.2018.04.11.18.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 18:50:31 -0700 (PDT)
Message-ID: <5ACEBB47.3060300@huawei.com>
Date: Thu, 12 Apr 2018 09:49:59 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] should BIOS change the efi type when we set CONFIG_X86_RESERVE_LOW
 ?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: yeyunfeng <yeyunfeng@huawei.com>, Wenan Mao <maowenan@huawei.com>, Linux
 MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi, I find CONFIG_X86_RESERVE_LOW=64 in my system, so trim_low_memory_range()
will reserve low 64kb memory. But efi_free_boot_services() will free it to
buddy system again later because BIOS set the type to EFI_BOOT_SERVICES_CODE.

Here is the log:
...
efi: mem03: type=3, attr=0xf, range=[0x000000000000e000-0x0000000000010000) (0MB
...
