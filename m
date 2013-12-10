Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id E453A6B0075
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:31:33 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so4410529qcx.18
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:31:33 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id r10si4321440qak.98.2013.12.10.13.31.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Dec 2013 13:31:32 -0800 (PST)
Message-ID: <52A787D0.2070400@zytor.com>
Date: Tue, 10 Dec 2013 13:29:52 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,x86: fix span coverage in e820_all_mapped()
References: <52A6D9B0.7040506@huawei.com> <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
In-Reply-To: <CAE9FiQUd+sU4GEq0687u8+26jXJiJVboN90+L7svyosmm+V1Rg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 12/10/2013 01:06 PM, Yinghai Lu wrote:
> On Tue, Dec 10, 2013 at 1:06 AM, Xishi Qiu <qiuxishi@huawei.com> wrote:
>> In the following case, e820_all_mapped() will return 1.
>> A < start < B-1 and B < end < C, it means <start, end> spans two regions.
>> <start, end>:           [start - end]
>> e820 addr:          ...[A - B-1][B - C]...
> 
> should be [start, end) right?
> and
> [A, B),[B, C)
> 

What happens if it spans more than two regions?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
