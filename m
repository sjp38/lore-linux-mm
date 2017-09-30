Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07DE46B0069
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 18:36:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u138so1977684wmu.2
        for <linux-mm@kvack.org>; Sat, 30 Sep 2017 15:36:07 -0700 (PDT)
Received: from iam.tj (yes.iam.tj. [109.74.197.121])
        by mx.google.com with ESMTPS id 12si4915063wmg.117.2017.09.30.15.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Sep 2017 15:36:06 -0700 (PDT)
From: Tj <linux@iam.tj>
Subject: Regression: x86/mm: Add Secure Memory Encryption (SME) support
Message-ID: <d5c60048-dbb3-0440-d139-ea325621e654@iam.tj>
Date: Sat, 30 Sep 2017 23:36:35 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org

With 4.14.0rc2 on an Intel CPU with an Nvidia GPU the proprietary nvidia
driver (v340.102) fails to modpost due to:

FATAL: modpost: GPL-incompatible module nvidia.ko uses GPL-only symbol
'sme_me_mask'

I think this is due to:

config ARCH_HAS_MEM_ENCRYPT
       def_bool y


I noticed that a grep of the built kernel for "sme_me_mask" shows the
symbol imported into more than 300 modules on an Ubuntu mainline build
of 4.14.0-041400rc2-lowlatency.

Should the new symbol be referenced so widely and how can it be
prevented from being included in proprietary modules on systems that
don't have SME even if the kernel is built with it enabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
