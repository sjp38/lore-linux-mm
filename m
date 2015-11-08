Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 867076B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 15:11:32 -0500 (EST)
Received: by ykfs79 with SMTP id s79so6740562ykf.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 12:11:32 -0800 (PST)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id q127si5271971ywe.246.2015.11.08.12.11.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 12:11:31 -0800 (PST)
Received: by ykba4 with SMTP id a4so235442558ykb.3
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 12:11:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201511081404.HGJ65681.LOSJFOtMFOVHFQ@I-love.SAKURA.ne.jp>
References: <1446896665-21818-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<CAHp75VfuH3oBSTmz1ww=H=q0btxBft+Z2Rdzav3VHHZypk6GVQ@mail.gmail.com>
	<CAHp75Vds+xA+Mtb1rCM8ALsgiGmY3MeYs=HjYuaFzSyH1L_C0A@mail.gmail.com>
	<201511081404.HGJ65681.LOSJFOtMFOVHFQ@I-love.SAKURA.ne.jp>
Date: Sun, 8 Nov 2015 22:11:31 +0200
Message-ID: <CAHp75Vc+J9hgGkdfQeZCQhbOMBdy-f8YfqxL8Z-gdXYPePfuzg@mail.gmail.com>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Julia Lawall <julia@diku.dk>, Joe Perches <joe@perches.com>, mhocko@kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Nov 8, 2015 at 7:04 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Andy Shevchenko wrote:
>> Like Joe noticed you have left few places like
>> void my_func_kvfree(arg)
>> {
>> kvfree(arg);
>> }
>>
>> Might make sense to remove them completely, especially in case when
>> you have changed the callers.
>
> I think we should stop at
>
> #define my_func_kvfree(arg) kvfree(arg)

I don't think it's a good idea.

>
> in case someone want to add some code in future.

=E2=80=A6then leave them to decide what to do, no? Trying to hunt the probl=
em
which rather will not happen.

>
> Also, we might want to add a helper that does vmalloc() when
> kmalloc() failed because locations that do
>
>   ptr =3D kmalloc(size, GFP_NOFS);
>   if (!ptr)
>       ptr =3D vmalloc(size); /* Wrong because GFP_KERNEL is used implicit=
ly */
>
> are found.

Another patch like Sergey suggested.

>
>> One more thought. Might be good to provide a coccinelle script for
>> such places? Julia?
>
> Welcome. I'm sure I'm missing some locations.



--=20
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
