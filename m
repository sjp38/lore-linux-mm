Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 134836B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:20:45 -0400 (EDT)
Received: by pvg11 with SMTP id 11so139117pvg.14
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 08:20:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1271255053.7196.89.camel@localhost.localdomain>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <1271255053.7196.89.camel@localhost.localdomain>
Date: Thu, 15 Apr 2010 00:12:45 +0900
Message-ID: <h2m28c262361004140812y92447e97z29c001d0a8b8eaaf@mail.gmail.com>
Subject: Re: vmalloc performance
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <steve@chygwyn.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 11:24 PM, Steven Whitehouse <steve@chygwyn.com> wro=
te:
> Hi,
>
> Also, what lock should be protecting this code:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0va->flags |=3D VM_LAZY_FREE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_add((va->va_end - va->va_start) >> PAGE=
_SHIFT,
> &vmap_lazy_nr);
>
> in free_unmap_vmap_area_noflush() ? It seem that if
> __purge_vmap_area_lazy runs between the two statements above that the
> number of pages contained in vmap_lazy_nr will be incorrect. Maybe the
> two statements should just be reversed? I can't see any reason that the
> flag assignment would be atomic either. In recent tests, including the
> patch below, the following has been reported to me:

It was already fixed.
https://patchwork.kernel.org/patch/89783/

Thanks.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
