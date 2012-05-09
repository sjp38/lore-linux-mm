Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 21A6C6B00FA
	for <linux-mm@kvack.org>; Wed,  9 May 2012 02:30:43 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so84586vbb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 23:30:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201205031634316254497@gmail.com>
References: <201205031634316254497@gmail.com>
Date: Wed, 9 May 2012 09:30:42 +0300
Message-ID: <CAOJsxLHDA+_AYBCUu2ZqTt6A6G1a5qxc3KwBi2pXMNK_N4AKLw@mail.gmail.com>
Subject: Re: [PATCH] Documentations: Fix slabinfo.c directory in vm/slub.txt
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>

On Thu, May 3, 2012 at 11:34 AM, majianpeng <majianpeng@gmail.com> wrote:
> Because the place of slabinfo.c changed.So update in slub.txt.
>
> Signed-off-by: majianpeng <majianpeng@gmail.com>

Is that really your legal name? You cannot sign-off patches with
pseudonyms for the Linux kernel.

Can you please fix the signoff and resend with Christoph's ACK? Thanks!

> ---
> =A0Documentation/vm/slub.txt | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
> index 6752870..b0c6d1b 100644
> --- a/Documentation/vm/slub.txt
> +++ b/Documentation/vm/slub.txt
> @@ -17,7 +17,7 @@ data and perform operation on the slabs. By default sla=
binfo only lists
> =A0slabs that have data in them. See "slabinfo -h" for more options when
> =A0running the command. slabinfo can be compiled with
>
> -gcc -o slabinfo tools/slub/slabinfo.c
> +gcc -o slabinfo tools/vm/slabinfo.c
>
> =A0Some of the modes of operation of slabinfo require that slub debugging
> =A0be enabled on the command line. F.e. no tracking information will be
> --
> 1.7.5.4
>
> --------------
> majianpeng
> 2012-05-03
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
