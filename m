Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D08F828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 12:40:45 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so162302119lfg.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 09:40:45 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id g62si718982ljg.36.2016.07.06.09.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 09:40:43 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id h129so158510929lfh.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 09:40:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577CB5FD.8050709@virtuozzo.com>
References: <1467766348-22419-1-git-send-email-iamjoonsoo.kim@lge.com> <577CB5FD.8050709@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 6 Jul 2016 18:40:42 +0200
Message-ID: <CAG_fn=WQDL1hUbqt84CUOjTkOu7ySKQ+SWenWA+5dm-rmV0OKw@mail.gmail.com>
Subject: Re: [PATCH v5] kasan/quarantine: fix bugs on qlist_move_cache()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Kuthonuzo Luruo <poll.stdin@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Jul 6, 2016 at 9:40 AM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 07/06/2016 03:52 AM, js1304@gmail.com wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> There are two bugs on qlist_move_cache(). One is that qlist's tail
>> isn't set properly. curr->next can be NULL since it is singly linked
>> list and NULL value on tail is invalid if there is one item on qlist.
>> Another one is that if cache is matched, qlist_put() is called and
>> it will set curr->next to NULL. It would cause to stop the loop
>> prematurely.
>>
>> These problems come from complicated implementation so I'd like to
>> re-implement it completely. Implementation in this patch is really
>> simple. Iterate all qlist_nodes and put them to appropriate list.
Neat trick :)
>> Unfortunately, I got this bug sometime ago and lose oops message.
>> But, the bug looks trivial and no need to attach oops.
>>
>> v5: rename some variable for better readability
>> v4: fix cache size bug s/cache->size/obj_cache->size/
>> v3: fix build warning
>>
>> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine implementation=
")
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>
Acked-by: Alexander Potapenko <glider@google.com>


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
