Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5362EC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:38:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 080CA2070B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:38:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fr9l8juY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 080CA2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97AF08E0045; Thu, 25 Jul 2019 03:38:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92BF58E0031; Thu, 25 Jul 2019 03:38:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 819C18E0045; Thu, 25 Jul 2019 03:38:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61BA88E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:38:08 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id v11so53949968iop.7
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:38:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xNvB2ONftmaWiXRhMLu1nth3BAaraeOQSf/+WChcARs=;
        b=SEhgdHCi0npZz6Ngq2UMdP43LvvZqYOSfzjozmuSnqnSkTGCEl0qAoAmn3TKopCu++
         wxxVZFolOS3dfMrIg7rxE9t1HmOmDNaATVhkbAIAddTjIFQLVRzEcm05vUkKa+eMMwit
         O86b4P9ZZBPXfdJn4W1fcLsl98T5EmpuxhcObfMxTp86fwGdwtOk0+XwuEqqfypo3MSV
         BsPAa5ShhxcFeRZNb0OLB1qt/T59f+52cutY2LHru9N+QMXi7utgcU/g8KA2jAdC3m0O
         dmJcTh5zxxagOeqPPv6GuxCgKSpYn/DRCZRc7UbudcwsSpEPDA7vMt2tizLmivexrDfE
         lEjg==
X-Gm-Message-State: APjAAAWxMfUVyJqn5zVd+WANJX0wwKqc6QUUHU0HPhiSDyU2JCywpqIU
	RRGPVzN2+SCyLwRpeDOQyBUf1KKpu2s5qySPghAVPHt4GNWhP8bL7gkqXc0aye9T+1pPABg0noS
	aZJPGOoSiKLCSJrxcPtVZncMEkglTaIXKxxrH+9yFMbaMKfLNHosSnKljuDzh6iYzVg==
X-Received: by 2002:a02:cc6c:: with SMTP id j12mr46577970jaq.102.1564040288174;
        Thu, 25 Jul 2019 00:38:08 -0700 (PDT)
X-Received: by 2002:a02:cc6c:: with SMTP id j12mr46577917jaq.102.1564040287430;
        Thu, 25 Jul 2019 00:38:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564040287; cv=none;
        d=google.com; s=arc-20160816;
        b=iMnBC4uKLxoSQL/ML1kCLy71fbvjDK0nuEN/TJyVT+X4NCKCcJ5we/kr8ZEf/Mo1pz
         rGYpryIbvNlRsK5/3jf+mjBV0S7NAYDSQAKzZ46dBJ75/Rkd102TVxCpe0mR/xFeGb33
         74e910p6ebe36lHPyv6jo37Hy+jHZL8aQncts/vtQdBbP5l3I2anfF4HN0n2epDVpSrP
         5efXNAUhoTUHTdfv/yYZfRkVtvCFInCws2tFDOd9d5c8RrvMqu7FCXUCrYSX/ZHMWwVD
         Uv+c0l4xWL65LeFQqldosth0rufhmUNXf/C2Odtezxz3w8C753HneX3ONGahHihTeH7Q
         Evtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xNvB2ONftmaWiXRhMLu1nth3BAaraeOQSf/+WChcARs=;
        b=OLduJSH1+2VHjhwj8sDZvzGlwJMCz8Uu3IKll5GbCi6w19B8SIsSP/is0B3SOiCGTx
         v8QfqoqZgkAFu0fvGgHSX4nqdQinTYm7cxH5jqmM1J0/YXbeAguL8ikCQK7fePQlZpo/
         kufSRquK074wR07FtXApsr7dIgihULLVJNQ6o7bPTu4ZRQclhLW0aWqqZ2asLduIyaCZ
         D2MFXGtkh5rDa3wXJsdtlh5BBNq0X5agozCvDoF+fztrPAuZCMSgBGhuS5YYvQDPhq/E
         h1jhbDI4pPkTfCEuOVwq8PpPBgaQ49JW+vKUnzJJJR60b7qN3zlyVVMFUEh7n2Hp+rgu
         HDMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fr9l8juY;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor32231200iog.11.2019.07.25.00.38.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 00:38:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fr9l8juY;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xNvB2ONftmaWiXRhMLu1nth3BAaraeOQSf/+WChcARs=;
        b=fr9l8juYjQ/JeEFFeRXMS2hULLCf6FmgD0GiXuRPt9+/6vbFkhv5fQao4HtvkA1nSN
         Hundf5061xCvw3cztPVqXSkqRTGK2+vMqrMfb6feMfOQ9OzGEep8DHobwE2pjj0luZkN
         jm4UXpBAwsX5vgWkM5f58ag9ySz5Auqvwhj45Z+rASuMKRl/VGpS3UNX8EE+ii+HoduO
         j5niOd6+lCwe5LWAv/h2Go0EtQiyr6jxuu2YVp+rAFkGEG1IuRGMMLrQJC0JJlyYGvj4
         +3bXp60tPupGxnNuv+VayoQQCoO0u2dT4jt71tRA9pjZUp4TDvss4i/07EobyLH5SMbJ
         svLw==
X-Google-Smtp-Source: APXvYqyTIhEg25V35EKAUow1cficLpe2IWeBlMVkavYr91rSmxFP0dG+elET2304HhNnBYyHzZ/DpaNs09dqyAhP+4Q=
X-Received: by 2002:a6b:b556:: with SMTP id e83mr78484315iof.94.1564040286860;
 Thu, 25 Jul 2019 00:38:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-3-dja@axtens.net>
In-Reply-To: <20190725055503.19507-3-dja@axtens.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 25 Jul 2019 09:37:55 +0200
Message-ID: <CACT4Y+YDjnv_GhGkN7MfjTD-KmA8W6uDkwn0isxRoANTVFD8ew@mail.gmail.com>
Subject: Re: [PATCH 2/3] fork: support VMAP_STACK with KASAN_VMALLOC
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
>
> Supporting VMAP_STACK with KASAN_VMALLOC is straightforward:
>
>  - clear the shadow region of vmapped stacks when swapping them in
>  - tweak Kconfig to allow VMAP_STACK to be turned on with KASAN
>
> Signed-off-by: Daniel Axtens <dja@axtens.net>

Reviewed-by: Dmitry Vyukov <dvyukov@google.com>

> ---
>  arch/Kconfig  | 9 +++++----
>  kernel/fork.c | 4 ++++
>  2 files changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index a7b57dd42c26..e791196005e1 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -825,16 +825,17 @@ config HAVE_ARCH_VMAP_STACK
>  config VMAP_STACK
>         default y
>         bool "Use a virtually-mapped stack"
> -       depends on HAVE_ARCH_VMAP_STACK && !KASAN
> +       depends on HAVE_ARCH_VMAP_STACK
> +       depends on !KASAN || KASAN_VMALLOC
>         ---help---
>           Enable this if you want the use virtually-mapped kernel stacks
>           with guard pages.  This causes kernel stack overflows to be
>           caught immediately rather than causing difficult-to-diagnose
>           corruption.
>
> -         This is presently incompatible with KASAN because KASAN expects
> -         the stack to map directly to the KASAN shadow map using a formula
> -         that is incorrect if the stack is in vmalloc space.
> +         To use this with KASAN, the architecture must support backing
> +         virtual mappings with real shadow memory, and KASAN_VMALLOC must
> +         be enabled.
>
>  config ARCH_OPTIONAL_KERNEL_RWX
>         def_bool n
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d8ae0f1b4148..ce3150fe8ff2 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -94,6 +94,7 @@
>  #include <linux/livepatch.h>
>  #include <linux/thread_info.h>
>  #include <linux/stackleak.h>
> +#include <linux/kasan.h>
>
>  #include <asm/pgtable.h>
>  #include <asm/pgalloc.h>
> @@ -215,6 +216,9 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>                 if (!s)
>                         continue;
>
> +               /* Clear the KASAN shadow of the stack. */
> +               kasan_unpoison_shadow(s->addr, THREAD_SIZE);
> +
>                 /* Clear stale pointers from reused stack. */
>                 memset(s->addr, 0, THREAD_SIZE);
>
> --
> 2.20.1
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190725055503.19507-3-dja%40axtens.net.

