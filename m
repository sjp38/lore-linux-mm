Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id EBC186B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 14:05:35 -0500 (EST)
From: =?utf-8?B?UmFkb3PFgmF3?= Smogura <mail@smogura.eu>
Subject: Re: [PATCH] mm: Change of refcounting method for compound page.
Date: Fri, 03 Feb 2012 20:05:27 +0100
Message-ID: <1383050.EiyE3vO7UJ@localhost>
In-Reply-To: <1328290093-19294-2-git-send-email-mail@smogura.eu>
References: <1328290093-19294-1-git-send-email-mail@smogura.eu> <1328290093-19294-2-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Yongqiang Yang <xiaoqiangnk@gmail.com>

Dnia pi=C4=85tek, 3 lutego 2012 o 18:28:13 Rados=C5=82aw Smogura napisa=
=C5=82(a):
> Compound pages are now refcounted in way allowing tracking of tail pa=
ges
> and automatically free of compound page when all references (counter)=

> fell to zero. This in addition make get_page and get_page_unless_zero=

> similar in work, as well put_page and put_page_unless_zero. In additi=
on
> it  makes procedures more friendly. One thing that should be taken, b=
y
> developer, on account is to take care when page is putted or geted wh=
en
> compound lock is obtained, to avoid deadlocks. Locking is used to
> prevent concurrent compound split and only when page refcount goes fr=
om
> 0 to 1 or vice versa.
>=20
> Technically implementation uses 3rd element of compound page to store=

> "tails usage counter". This counter is decremented when tail pages co=
unt
> goes to zero, and bumped when tail page is getted from zero usage
> (recovered) =E2=80=93 this is to keep backward compatible usage of ta=
il pages.
> If "tails usage counter" fell to zero head counter is decremented, if=

> "tails usage counter" is increased to one the head count is increased=
,
> too. For compound pages without 3rd element (order of 1, two pages) 2=
nd
> page count is used in similar way as for higher order pages.
>=20
> Signed-off-by: Rados=C5=82aw Smogura <mail@smogura.eu>
> ---
>  include/linux/mm.h       |   94 ++++++++++++-----
>  include/linux/mm_types.h |   24 ++++-
>  include/linux/pagemap.h  |    1 -
>  mm/huge_memory.c         |   25 +----
>  mm/internal.h            |   46 ---------
>  mm/memory.c              |    2 +-
>  mm/page_alloc.c          |    2 +
>  mm/swap.c                |  254
> +++++++++++++++++++++++++++++----------------- 8 files changed, 256
> insertions(+), 192 deletions(-)
<snip>
I would like to say huge sorry, I sent wrong patch (yesterday work). Pl=
ease=20
discard previous patch, and consider patch I will send in reply to this=
 email.=20
Not included change was introduced to allow proper concurrent work of g=
et/put=20
page and split page .

Regards,
Rados=C5=82aw Smogura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
