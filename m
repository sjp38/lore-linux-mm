Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E578A6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 04:43:37 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so351439pbc.14
        for <linux-mm@kvack.org>; Tue, 14 Feb 2012 01:43:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214005301.a9d5be1a.akpm@linux-foundation.org>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com> <20120214005301.a9d5be1a.akpm@linux-foundation.org>
From: Yang Bai <hamo.by@gmail.com>
Date: Tue, 14 Feb 2012 17:43:17 +0800
Message-ID: <CAO_0yfOjstSnhqf_DBBr7-it48GyUObF2=4GeMd7TDo_TPaLPg@mail.gmail.com>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 14, 2012 at 4:53 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 14 Feb 2012 15:28:19 +0800 Yang Bai <hamo.by@gmail.com> wrote:
>
>
> One of the applications of kcalloc() is to prevent userspace from
> causing a multiplicative overflow (and then perhaps causing an
> overwrite beyond the end of the allocated memory).
>
> With this patch, we've just handed the user a way of spamming the logs
> at 1MHz. =C2=A0This is bad.
>
>
> Also, please let's not randomly add debug stuff in places where we've
> never demonstrated a need for it.

Ok. Please just drop this patch.

Thanks.

--=20
=C2=A0 =C2=A0 """
=C2=A0 =C2=A0 Keep It Simple,Stupid.
=C2=A0 =C2=A0 """

Chinese Name: =E7=99=BD=E6=9D=A8
Nick Name: Hamo
Homepage: http://hamobai.com/
GPG KEY ID: 0xA4691A33
Key fingerprint =3D 09D5 2D78 8E2B 0995 CF8E=C2=A0 4331 33C4 3D24 A469 1A33

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
