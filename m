Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 03B146B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:33:14 -0500 (EST)
Received: by mail-lf0-f54.google.com with SMTP id 17so23073203lfz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:33:13 -0800 (PST)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id pj3si5153375lbb.88.2016.01.28.01.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 01:33:12 -0800 (PST)
Received: by mail-lb0-x22b.google.com with SMTP id x4so20394733lbm.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:33:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453972263-25907-1-git-send-email-sudipm.mukherjee@gmail.com>
References: <1453972263-25907-1-git-send-email-sudipm.mukherjee@gmail.com>
Date: Thu, 28 Jan 2016 12:33:12 +0300
Message-ID: <CALYGNiNvUFyPCNvPiDSbXHiSTmYCfwPwVGeYqzhNe8SmM+bfMQ@mail.gmail.com>
Subject: Re: [PATCH] mm: provide reference to READ_IMPLIES_EXEC
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-testers@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 28, 2016 at 12:11 PM, Sudip Mukherjee
<sudipm.mukherjee@gmail.com> wrote:
> blackfin defconfig fails with the error:
> mm/internal.h: In function 'is_stack_mapping':
> arch/blackfin/include/asm/page.h:15:27: error: 'READ_IMPLIES_EXEC' undeclared
>
> Commit 07dff8ae2bc5 has added is_stack_mapping in mm/internal.h but it
> also needs personality.h.

I have different patch which should fix this too.
It removes usage of VM_STACK_DEFAULT_FLAGS from that file.

>
> Fixes: 07dff8ae2bc5 ("mm: warn about VmData over RLIMIT_DATA")
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>
> build log at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/105335848
>
>  mm/internal.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index cac6eb4..59c496f 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -14,6 +14,7 @@
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/pagemap.h>
> +#include <linux/personality.h>
>  #include <linux/tracepoint-defs.h>
>
>  /*
> --
> 1.9.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
