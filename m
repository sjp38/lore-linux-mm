Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 015F56B0068
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 02:10:57 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7497942pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 23:10:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120616045637.GA2331@kernel>
References: <alpine.LSU.2.00.1206151752420.8741@eggly.anvils>
	<20120616045637.GA2331@kernel>
Date: Sat, 16 Jun 2012 14:10:56 +0800
Message-ID: <CAM_iQpXPH2SgjKbj1g5azcddusBmQ0CDvDz_RJe2r2HSTo51yA@mail.gmail.com>
Subject: Re: [PATCH] swap: fix shmem swapping when more than 8 areas
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jun 16, 2012 at 12:56 PM, Wanpeng Li <liwp.linux@gmail.com> wrote:
>>-#define SWP_TYPE_SHIFT(e) =C2=A0 =C2=A0 (sizeof(e.val) * 8 - MAX_SWAPFIL=
ES_SHIFT)
>>+#define SWP_TYPE_SHIFT(e) =C2=A0 =C2=A0 ((sizeof(e.val) * 8) - \
>>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0(MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT))
>
> Hi Hugh,
>
> Since SHIFT =3D=3D MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT =3D=
=3D 7
> and the low two bits used for radix_tree, the available swappages number
> based of 32bit architectures reduce to 2^(32-7-2) =3D 32GB?
>

The lower two bits are in the 7 bits you calculated,
so it is 2^(32-7), not 2^(32-7-2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
