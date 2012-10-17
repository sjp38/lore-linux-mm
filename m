Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 1A53A6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 21:44:12 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so8357447obc.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 18:44:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <COL115-DS17FCFB8683288781F8E011BC770@phx.gbl>
References: <COL115-DS17FCFB8683288781F8E011BC770@phx.gbl>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 16 Oct 2012 21:43:51 -0400
Message-ID: <CAHGf_=p__OFKsP=qf+RP28gZntYAwzq-gNnQ61UR_kJuFL7OSw@mail.gmail.com>
Subject: Re: [help] kernel boot parameter "mem=xx" disparity
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jun Hu <duanshuidao@hotmail.com>
Cc: linux-mm <linux-mm@kvack.org>

On Tue, Oct 16, 2012 at 8:55 PM, Jun Hu <duanshuidao@hotmail.com> wrote:
> Hi Guys:
>
> My machine has 8G memory, when I use kernel boot parameter mem=3D5G , it =
only
> display =934084 M=94 using =93free =96m =93.
> where the =935120-4084 =3D 1036M =93 memory run?

mem is misleading parameter. It is not specify amount memoy. It is specify
maximum recognized address. Thus when your machine have some memory
hole, you see such result. Don't worry, recent regular machine often have
 ~1G hole.

Detailed memory map is logged in /var/log/messages as a part of boot messag=
es.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
