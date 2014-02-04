Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id F0C256B003B
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 12:02:49 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id gq1so9722875obb.21
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 09:02:49 -0800 (PST)
Received: from mail-oa0-x235.google.com (mail-oa0-x235.google.com [2607:f8b0:4003:c02::235])
        by mx.google.com with ESMTPS id o4si1315259oei.72.2014.02.04.09.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 09:02:49 -0800 (PST)
Received: by mail-oa0-f53.google.com with SMTP id m1so10096453oag.40
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 09:02:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1391533134-2234-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1391533134-2234-1-git-send-email-kosaki.motohiro@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 4 Feb 2014 12:02:29 -0500
Message-ID: <CAHGf_=qdtQsxE3vYcmUgSre=MiTd7ycYSFCeiTGD2z7b+eE36A@mail.gmail.com>
Subject: Re: [PATCH] __set_page_dirty uses spin_lock_irqsave instead of spin_lock_irq
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, Feb 4, 2014 at 11:58 AM,  <kosaki.motohiro@gmail.com> wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> To use spin_{un}lock_irq is dangerous if caller disabled interrupt.
> spin_lock_irqsave is a safer alternative. Luckily, now there is no
> caller that has such usage but it would be nice to fix.
>
> Reported-by: David Rientjes rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Self Nack this. There IS a caller and we should send this to stable.
I'll respin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
