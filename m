Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B15436B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:31:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so32987093wjc.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:31:08 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id e140si7390620wmd.117.2016.11.30.06.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 06:31:07 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id a20so29829639wme.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:31:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <583E8864.9000305@huawei.com>
References: <583E8864.9000305@huawei.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Date: Wed, 30 Nov 2016 17:31:06 +0300
Message-ID: <CAPAsAGyWSZRGs-PJsBa-fb8yhcXmdCZ0+ZVwh6bWuvc-v+2HvQ@mail.gmail.com>
Subject: Re: [RFC] kasan: is it a wrong report from kasan?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: yang.shi@linaro.org, Steven Rostedt <rostedt@goodmis.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, wangwei <bessel.wang@huawei.com>

2016-11-30 11:05 GMT+03:00 Xishi Qiu <qiuxishi@huawei.com>:
> The kernel version is v4.1, and I find some error reports from kasan.
> I'm not sure whether it is a wrong report.
>

This looks like false positive that was fixed in 0d97e6d8024("arm64:
kasan: clear stale stack poison").
Also you might need e1b77c92981a("sched/kasan: remove stale KASAN
poison after hotplug") too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
