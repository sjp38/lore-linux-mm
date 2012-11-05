Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9C3486B002B
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 22:31:53 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id fl17so6816410vcb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 19:31:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1d-rw_vkDF98fcf9E0=h86dsp+83-0_RE5b482juxaGVw@mail.gmail.com>
References: <508086DA.3010600@oracle.com>
	<5089A05E.7040000@gmail.com>
	<CA+1xoqf2v_jEapwU68BzXyi4abSRmi_=AiaJVHM3dBbHtsBnqQ@mail.gmail.com>
	<CAA_GA1d-rw_vkDF98fcf9E0=h86dsp+83-0_RE5b482juxaGVw@mail.gmail.com>
Date: Sun, 4 Nov 2012 19:31:52 -0800
Message-ID: <CANN689HXoCMTP4ZRMUNOGAdOBmizKyo6jMqbqAFx8wwPXp+AzQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in anon_vma_interval_tree_verify
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Sun, Nov 4, 2012 at 6:20 PM, Bob Liu <lliubbo@gmail.com> wrote:
> The loop for each entry of vma->anon_vma_chain in validate_mm() is not
> protected by anon_vma lock.
> I think that may be the cause.
>
> Michel, What's your opinion=EF=BC=9F

Good catch, I think that's it. Somehow it had not occured to me to
verify the checker code - as in, who's checking the checker ? :)

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
