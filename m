Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 30E216B01B5
	for <linux-mm@kvack.org>; Fri, 21 May 2010 01:49:03 -0400 (EDT)
Received: by qyk29 with SMTP id 29so250614qyk.14
        for <linux-mm@kvack.org>; Thu, 20 May 2010 22:49:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimJ_ROa55mX9sCs9TkoBZFEze5Ak-LQsAMeeigq@mail.gmail.com>
References: <AANLkTimAF1zxXlnEavXSnlKTkQgGD0u9UqCtUVT_r9jV@mail.gmail.com>
	<AANLkTimUYmUCdFMIaVi1qqcz2DqGoILeu43XWZBHSILP@mail.gmail.com>
	<AANLkTikTYbPKTaEMbdwGikV1Og4VQtXUCgNq0EldbR4U@mail.gmail.com>
	<AANLkTimJ_ROa55mX9sCs9TkoBZFEze5Ak-LQsAMeeigq@mail.gmail.com>
From: dave b <db.pub.mail@gmail.com>
Date: Fri, 21 May 2010 15:48:40 +1000
Message-ID: <AANLkTimS2wdaCtYM3LYhCj2lvMFUPpK4oBBW1QdOoiBA@mail.gmail.com>
Subject: Fwd: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---------- Forwarded message ----------
From: dave b <db.pub.mail@gmail.com>
Date: 14 May 2010 23:14
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
To: linux-kernel@vger.kernel.org


On 14 May 2010 22:53, dave b <db.pub.mail@gmail.com> wrote:
> In 2.6.3* kernels (test case was performed on the 2.6.33.3 kernel)
> when physical memory runs out and there is a large swap partition -
> the system completely stalls.
>
> I noticed that when running debian lenny using dm-crypt =C2=A0with
> encrypted / and swap with a =C2=A02.6.33.3 kernel (and all of the 2.6.3*
> series iirc) when all physical memory is used (swapiness was left at
> the default 60) the system hangs and does not respond. It can resume
> normal operation some time later - however it seems to take a *very*
> long time for the oom killer to come in. Obviously with swapoff this
> doesn't happen - the oom killer comes in and does its job.
>
>
> free -m
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=A0 used=
 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 shared =C2=A0 =C2=A0buffers =C2=A0=
 =C2=A0 cached
> Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01980 =C2=A0 =C2=A0 =C2=A0 1101 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0879 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 58 =C2=A0 =C2=A0 =C2=A0 =C2=A0201
> -/+ buffers/cache: =C2=A0 =C2=A0 =C2=A0 =C2=A0840 =C2=A0 =C2=A0 =C2=A0 11=
39
> Swap: =C2=A0 =C2=A0 =C2=A0 =C2=A024943 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A024943
>
>
> My simple test case is
>
> dd if=3D/dev/zero of=3D/tmp/stall
> and wait till /tmp fills...
>

>Sorry - I forgot to say I am running x86-64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
