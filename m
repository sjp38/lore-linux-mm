Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4716B0122
	for <linux-mm@kvack.org>; Tue, 26 May 2015 23:49:25 -0400 (EDT)
Received: by qchk10 with SMTP id k10so11557768qch.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 20:49:25 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 23si16754932qhc.26.2015.05.26.20.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 20:49:24 -0700 (PDT)
Received: by qkx62 with SMTP id 62so105379520qkx.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 20:49:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1432483292-23109-1-git-send-email-jungseoklee85@gmail.com>
References: <1432483292-23109-1-git-send-email-jungseoklee85@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 26 May 2015 23:49:03 -0400
Message-ID: <CAHGf_=oMDPscgJ0bdr+QrV24n3KL3BC5qe8KGa=dePxg4tc4Zg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] kernel/fork.c: add a function to calculate page
 address from thread_info
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, barami97@gmail.com, linux-arm-kernel@lists.infradead.org

On Sun, May 24, 2015 at 12:01 PM, Jungseok Lee <jungseoklee85@gmail.com> wrote:
> A current implementation assumes thread_info address is always correctly
> calculated via virt_to_page. It restricts a different approach, such as
> thread_info allocation from vmalloc space.
>
> This patch, thus, introduces an independent function to calculate page
> address from thread_info one.
>
> Suggested-by: Sungjinn Chung <barami97@gmail.com>
> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: linux-arm-kernel@lists.infradead.org
> ---
>  kernel/fork.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)

I haven't receive a path [2/2] and haven't review whole patches. But
this patch itself is OK to me.
Acked-by: KOSAKI Motohiro <kosaki.motohiro@fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
