Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8AEB6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 03:55:33 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id f62so13861950otf.6
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 00:55:33 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id r24si924821otc.526.2017.12.21.00.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 00:55:33 -0800 (PST)
Message-ID: <5A3B76EE.8020001@huawei.com>
Date: Thu, 21 Dec 2017 16:55:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] does ioremap() cause memory leak?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

When we use iounmap() to free the mapping, it calls unmap_vmap_area() to clear page table,
but do not free the memory of page table, right?

So when use ioremap() to mapping another area(incluce the area before), it may use
large mapping(e.g. ioremap_pmd_enabled()), so the original page table memory(e.g. pte memory)
will be lost, it cause memory leak, right?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
