Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 658A86B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 09:26:55 -0400 (EDT)
Received: by qwk4 with SMTP id 4so941517qwk.14
        for <linux-mm@kvack.org>; Sat, 10 Jul 2010 06:26:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100710105700.GD25806@cmpxchg.org>
References: <1278756353-6884-1-git-send-email-lliubbo@gmail.com>
	<20100710105700.GD25806@cmpxchg.org>
Date: Sat, 10 Jul 2010 21:26:53 +0800
Message-ID: <AANLkTimSde6WsI0ySznpmeKqShJfLpimikjrHN9RTpx8@mail.gmail.com>
Subject: Re: [PATCH] slob: remove unused funtion
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, Jul 10, 2010 at 6:57 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Sat, Jul 10, 2010 at 06:05:53PM +0800, Bob Liu wrote:
>> funtion struct_slob_page_wrong_size() is not used anymore, remove it
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0mm/slob.c | =C2=A0 =C2=A02 --
>> =C2=A01 files changed, 0 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/slob.c b/mm/slob.c
>> index d582171..832d2b5 100644
>> --- a/mm/slob.c
>> +++ b/mm/slob.c
>> @@ -109,8 +109,6 @@ struct slob_page {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page page;
>> =C2=A0 =C2=A0 =C2=A0 };
>> =C2=A0};
>> -static inline void struct_slob_page_wrong_size(void)
>> -{ BUILD_BUG_ON(sizeof(struct slob_page) !=3D sizeof(struct page)); }
>
> It is not unused! =C2=A0Try `make mm/slob.o' with the following patch
> applied:
>

Why ?
And I can compile it successfully after remove this funtion.
Thanks.

> diff --git a/mm/slob.c b/mm/slob.c
> index 23631e2..d50ff8e 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -106,6 +106,7 @@ struct slob_page {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page page;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> + =C2=A0 =C2=A0 =C2=A0 unsigned long foo;
> =C2=A0};
> =C2=A0static inline void struct_slob_page_wrong_size(void)
> =C2=A0{ BUILD_BUG_ON(sizeof(struct slob_page) !=3D sizeof(struct page)); =
}
>



--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
