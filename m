Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C73776B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 11:08:11 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x125so122378427pgb.5
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 08:08:11 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id x33si17858175plb.145.2017.03.20.08.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 08:08:10 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id n11so6407046pfg.2
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 08:08:10 -0700 (PDT)
Date: Mon, 20 Mar 2017 23:08:07 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH tip] x86/mm: Correct fixmap header usage on adaptable
 MODULES_END
Message-ID: <20170320150807.GA78291@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170317175034.4701-1-thgarnie@google.com>
 <20170319160333.GA1187@WeideMBP.lan>
 <CAJcbSZE5Kq4ew3hHSSpMkReNf54EVpetA0hU09YYtkE2j=8m9w@mail.gmail.com>
 <20170320011408.GA28871@WeideMacBook-Pro.local>
 <CAJcbSZFE9kgF81eHsbpQ_8Wsw-X=w93X=P8SHFqsaznEuF+XTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Content-Disposition: inline
In-Reply-To: <CAJcbSZFE9kgF81eHsbpQ_8Wsw-X=w93X=P8SHFqsaznEuF+XTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 20, 2017 at 07:31:17AM -0700, Thomas Garnier wrote:
>On Sun, Mar 19, 2017 at 6:14 PM, Wei Yang <richard.weiyang@gmail.com> wrot=
e:
>> On Sun, Mar 19, 2017 at 09:25:00AM -0700, Thomas Garnier wrote:
>>>On Sun, Mar 19, 2017 at 9:03 AM, Wei Yang <richard.weiyang@gmail.com> wr=
ote:
>>>> On Fri, Mar 17, 2017 at 10:50:34AM -0700, Thomas Garnier wrote:
>>>>>This patch remove fixmap header usage on non-x86 code that was
>>>>>introduced by the adaptable MODULE_END change.
>>>>
>>>> Hi, Thomas
>>>>
>>>> In this patch, it looks you are trying to do two things for my underst=
anding:
>>>> 1. To include <asm/fixmap.h> in asm/pagetable_64.h and remove the incl=
ude in
>>>> some of the x86 files
>>>> 2. Remove <asm/fixmap.h> in mm/vmalloc.c
>>>>
>>>> I think your change log covers the second task in the patch, but not n=
ot talk
>>>> about the first task you did in the patch. If you could mention it in =
commit
>>>> log, it would be good for maintain.
>>>
>>>I agree, I am not the best at writing commits (by far). What's the
>>>best way for me to correct that? (the bot seem to have taken it).
>>>
>>
>> Simply mention it in your commit log is enough to me.
>>
>
>I meant, do I send another patch or reply on in this thread and bot
>will pick it up?
>

I think it is necessary to send V2.

--=20
Wei Yang
Help you, Help me

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYz/BXAAoJEKcLNpZP5cTd49EP/37hjdpnoxhIqed7hQudunF8
c0iUNKywdIn4mP0Bewal0Ceg7Lo6OYXLl6igv7expYAVlIo8eHY8DIvNkdJGOWeU
MTj9uM6p8YyzDALOp9bFGz7NG/o7VzkA4jnBIgmptYUMqyqXaa6xUEATtYw5hY4h
XFBNDNYipt28ZKWK4n9PEEz9N+ZnBO/wSGy4qNUY+XGOd+QCFBacwjX4qdyua9FX
hoI35QYkf/zwNbjVy8jTb5rskUEcWbWiO0TIerghosEl92Azp+gKIlg/4ILiW7jH
rcnxzR0vgJucpNvmnDsbYdhDY42aLKzL9ZNVH7yAKwf8Evdz3cRcq3HPHcRFXsz/
wWAn1ZACSNJVaRm3sEqEVAsCet8GPO6nfVKT+KjjD1MhP11myqW0i+UWbVB639eZ
8UkP9itKHyXRyxNbDTpRja5mobaerYpOgWmWzvqDN3K05Penbs1DVtXf7HK9cNsz
3CA1VI3/u/KDj+1ZTCjJl9Io66hk7eFDGaRa9GwtGh0BjuA8YCnxumtdZvbc+/a8
Q5x3WZtcmTGiz4ONwlyIYvrZ21myFaROSSV/j/mns0QBl/F+cjzIit4j+8d/0NVB
i3EetvEHDJhwQtxO8uekpLU8UWUb2nMs2AtqB6rLCC+LCnX2zxuGohFwiOGNs+Ub
t8l/UGJ5bV5kvUCuC+XS
=18uu
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
