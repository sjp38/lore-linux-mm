Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3E106B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 04:58:38 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id d9so146432715itc.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:58:38 -0800 (PST)
Received: from mail-it0-x23a.google.com (mail-it0-x23a.google.com. [2607:f8b0:4001:c0b::23a])
        by mx.google.com with ESMTPS id z189si10328150ioz.136.2017.01.30.01.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 01:58:38 -0800 (PST)
Received: by mail-it0-x23a.google.com with SMTP id e137so36706730itc.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 01:58:38 -0800 (PST)
Date: Mon, 30 Jan 2017 01:58:37 -0800 (PST)
From: lukefrierson888@gmail.com
Message-Id: <09708a3e-ef88-4695-8f3e-2cb69210b9ca@googlegroups.com>
In-Reply-To: <1467294357-98002-1-git-send-email-dvyukov@google.com>
References: <1467294357-98002-1-git-send-email-dvyukov@google.com>
Subject: Re: [PATCH] kasan: add newline to messages
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1365_1791315218.1485770317503"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev <kasan-dev@googlegroups.com>
Cc: akpm@linux-foundation.org, ryabinin.a.a@gmail.com, glider@google.com, linux-mm@kvack.org, dvyukov@google.com

------=_Part_1365_1791315218.1485770317503
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On Thursday, June 30, 2016 at 8:46:02 AM UTC-5, dvyukov wrote:
> Currently GPF messages with KASAN look as follows:
> kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> Add newlines.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  arch/x86/mm/kasan_init_64.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index 1b1110f..0493c17 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -54,8 +54,8 @@ static int kasan_die_handler(struct notifier_block *self,
>  			     void *data)
>  {
>  	if (val == DIE_GPF) {
> -		pr_emerg("CONFIG_KASAN_INLINE enabled");
> -		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access");
> +		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> +		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
>  	}
>  	return NOTIFY_OK;
>  }
> -- 
> 2.8.0.rc3.226.g39d4020


------=_Part_1365_1791315218.1485770317503--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
