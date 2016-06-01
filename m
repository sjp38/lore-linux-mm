Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71F726B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 11:22:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o70so11407558lfg.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:22:59 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id f19si13531505lji.65.2016.06.01.08.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 08:22:58 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id s64so15330791lfe.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 08:22:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1464794430-5486-1-git-send-email-shuahkh@osg.samsung.com>
References: <1464794430-5486-1-git-send-email-shuahkh@osg.samsung.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 1 Jun 2016 17:22:57 +0200
Message-ID: <CAG_fn=UbgEkJ5rv0Em9nNthLOWqy7BZ7y9ZU3ub8QTF6t_VpYw@mail.gmail.com>
Subject: Re: [PATCH] kasan: change memory hot-add error messages to info messages
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuahkh@osg.samsung.com>
Cc: ryabinin@virtuozzo.com, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 1, 2016 at 5:20 PM, Shuah Khan <shuahkh@osg.samsung.com> wrote:
> Change the following memory hot-add error messages to info messages. Ther=
e
> is no need for these to be errors.
>
> [    8.221108] kasan: WARNING: KASAN doesn't support memory hot-add
> [    8.221117] kasan: Memory hot-add will be disabled
>
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> ---
> Note: This is applicable to 4.6 stable releases.
>
>  mm/kasan/kasan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 18b6a2b..28439ac 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -763,8 +763,8 @@ static int kasan_mem_notifier(struct notifier_block *=
nb,
>
>  static int __init kasan_memhotplug_init(void)
>  {
> -       pr_err("WARNING: KASAN doesn't support memory hot-add\n");
> -       pr_err("Memory hot-add will be disabled\n");
> +       pr_info("WARNING: KASAN doesn't support memory hot-add\n");
> +       pr_info("Memory hot-add will be disabled\n");
No objections, but let's wait for Andrey.
>         hotplug_memory_notifier(kasan_mem_notifier, 0);
>
> --
> 2.7.4
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
