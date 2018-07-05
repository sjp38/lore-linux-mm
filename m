Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2CD46B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 17:02:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l21-v6so1254058pff.3
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 14:02:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bd11-v6sor2412181plb.131.2018.07.05.14.02.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 14:02:16 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
 <CAAeHK+xz552VNpZxgWwU-hbTqF5_F6YVDw3fSv=4OT8mNrqPzg@mail.gmail.com>
 <20180628124039.8a42ab5e2994fb2876ff4f75@linux-foundation.org>
 <CAAeHK+xsBOKghUp9XhpfXGqU=gjSYuy3G2GH14zWNEmaLPy8_w@mail.gmail.com>
 <20180629194117.01b2d31e805808eee5c97b4d@linux-foundation.org>
 <CAFKCwrjxGEa6CLJnjmNy+92d2GSUkoymQ6Sm91CDpMZcJCcWCA@mail.gmail.com>
 <20180702122112.267261b1e1609cf522753cf3@linux-foundation.org> <CAFKCwri_W8qEw-qMs+gXGqMGdZO82WpCiVpzcG4kinEyL7+zGg@mail.gmail.com>
In-Reply-To: <CAFKCwri_W8qEw-qMs+gXGqMGdZO82WpCiVpzcG4kinEyL7+zGg@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Fri, 6 Jul 2018 06:02:04 +0900
Message-ID: <CAKwvOdnv+3Pi2rh7-PhjGkMz34OPaP3O_NtpDjwoV1sgTqMB8w@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: multipart/alternative; boundary="000000000000b088ae057046dc1f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

--000000000000b088ae057046dc1f
Content-Type: text/plain; charset="UTF-8"

On Tue, Jul 3, 2018, 5:22 AM Evgenii Stepanov <eugenis@google.com> wrote:

> On Mon, Jul 2, 2018 at 12:21 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Mon, 2 Jul 2018 12:16:42 -0700 Evgenii Stepanov <eugenis@google.com>
> wrote:
> >
> >> On Fri, Jun 29, 2018 at 7:41 PM, Andrew Morton
> >> <akpm@linux-foundation.org> wrote:
> >> > On Fri, 29 Jun 2018 14:45:08 +0200 Andrey Konovalov <
> andreyknvl@google.com> wrote:
> >> >
> >> >> >> What kind of memory consumption testing would you like to see?
> >> >> >
> >> >> > Well, 100kb or so is a teeny amount on virtually any machine.  I'm
> >> >> > assuming the savings are (much) more significant once the machine
> gets
> >> >> > loaded up and doing work?
> >> >>
> >> >> So with clean kernel after boot we get 40 kb memory usage. With KASAN
> >> >> it is ~120 kb, which is 200% overhead. With KHWASAN it's 50 kb, which
> >> >> is 25% overhead. This should approximately scale to any amounts of
> >> >> used slab memory. For example with 100 mb memory usage we would get
> >> >> +200 mb for KASAN and +25 mb with KHWASAN. (And KASAN also requires
> >> >> quarantine for better use-after-free detection). I can explicitly
> >> >> mention the overhead in %s in the changelog.
> >> >>
> >> >> If you think it makes sense, I can also make separate measurements
> >> >> with some workload. What kind of workload should I use?
> >> >
> >> > Whatever workload people were running when they encountered problems
> >> > with KASAN memory consumption ;)
> >> >
> >> > I dunno, something simple.  `find / > /dev/null'?
> >> >
> >>
> >> Looking at a live Android device under load, slab (according to
> >> /proc/meminfo) + kernel stack take 8-10% available RAM (~350MB).
> >> Kasan's overhead of 2x - 3x on top of it is not insignificant.
> >>
> >
> > (top-posting repaired.  Please don't)
> >
> > For a debugging, not-for-production-use feature, that overhead sounds
> > quite acceptable to me.  What problems is it known to cause?
>
> Not having this overhead enables near-production use - ex. running
> kasan/khasan kernel on a personal, daily-use device to catch bugs that
> do not reproduce in test configuration. These are the ones that often
> cost the most engineering time to track down.
>
> CPU overhead is bad, but generally tolerable. RAM is critical, in our
> experience. Once it gets low enough, OOM-killer makes your life
> miserable.
>

This would be great actually. It's hard internally to get testers to run
KASAN builds on their daily devices. I would prefer even if we didn't ship
in production, to at least have internal testers using this build, as we
have great panic reporting/collection.

>

--000000000000b088ae057046dc1f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Tue, Jul 3, 2018, 5:22 AM Evgenii Stepanov &lt;<a href=3D"mailto:eugenis=
@google.com">eugenis@google.com</a>&gt; wrote:<br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">On Mon, Jul 2, 2018 at 12:21 PM, Andrew Morton<br>
&lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank" rel=3D"n=
oreferrer">akpm@linux-foundation.org</a>&gt; wrote:<br>
&gt; On Mon, 2 Jul 2018 12:16:42 -0700 Evgenii Stepanov &lt;<a href=3D"mail=
to:eugenis@google.com" target=3D"_blank" rel=3D"noreferrer">eugenis@google.=
com</a>&gt; wrote:<br>
&gt;<br>
&gt;&gt; On Fri, Jun 29, 2018 at 7:41 PM, Andrew Morton<br>
&gt;&gt; &lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank"=
 rel=3D"noreferrer">akpm@linux-foundation.org</a>&gt; wrote:<br>
&gt;&gt; &gt; On Fri, 29 Jun 2018 14:45:08 +0200 Andrey Konovalov &lt;<a hr=
ef=3D"mailto:andreyknvl@google.com" target=3D"_blank" rel=3D"noreferrer">an=
dreyknvl@google.com</a>&gt; wrote:<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt; &gt;&gt; What kind of memory consumption testing would yo=
u like to see?<br>
&gt;&gt; &gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt; &gt; Well, 100kb or so is a teeny amount on virtually any=
 machine.=C2=A0 I&#39;m<br>
&gt;&gt; &gt;&gt; &gt; assuming the savings are (much) more significant onc=
e the machine gets<br>
&gt;&gt; &gt;&gt; &gt; loaded up and doing work?<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; So with clean kernel after boot we get 40 kb memory usage=
. With KASAN<br>
&gt;&gt; &gt;&gt; it is ~120 kb, which is 200% overhead. With KHWASAN it&#3=
9;s 50 kb, which<br>
&gt;&gt; &gt;&gt; is 25% overhead. This should approximately scale to any a=
mounts of<br>
&gt;&gt; &gt;&gt; used slab memory. For example with 100 mb memory usage we=
 would get<br>
&gt;&gt; &gt;&gt; +200 mb for KASAN and +25 mb with KHWASAN. (And KASAN als=
o requires<br>
&gt;&gt; &gt;&gt; quarantine for better use-after-free detection). I can ex=
plicitly<br>
&gt;&gt; &gt;&gt; mention the overhead in %s in the changelog.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; If you think it makes sense, I can also make separate mea=
surements<br>
&gt;&gt; &gt;&gt; with some workload. What kind of workload should I use?<b=
r>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Whatever workload people were running when they encountered p=
roblems<br>
&gt;&gt; &gt; with KASAN memory consumption ;)<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I dunno, something simple.=C2=A0 `find / &gt; /dev/null&#39;?=
<br>
&gt;&gt; &gt;<br>
&gt;&gt;<br>
&gt;&gt; Looking at a live Android device under load, slab (according to<br=
>
&gt;&gt; /proc/meminfo) + kernel stack take 8-10% available RAM (~350MB).<b=
r>
&gt;&gt; Kasan&#39;s overhead of 2x - 3x on top of it is not insignificant.=
<br>
&gt;&gt;<br>
&gt;<br>
&gt; (top-posting repaired.=C2=A0 Please don&#39;t)<br>
&gt;<br>
&gt; For a debugging, not-for-production-use feature, that overhead sounds<=
br>
&gt; quite acceptable to me.=C2=A0 What problems is it known to cause?<br>
<br>
Not having this overhead enables near-production use - ex. running<br>
kasan/khasan kernel on a personal, daily-use device to catch bugs that<br>
do not reproduce in test configuration. These are the ones that often<br>
cost the most engineering time to track down.<br>
<br>
CPU overhead is bad, but generally tolerable. RAM is critical, in our<br>
experience. Once it gets low enough, OOM-killer makes your life<br>
miserable.<br></blockquote></div></div><div dir=3D"auto"><br></div><div dir=
=3D"auto">This would be great actually. It&#39;s hard internally to get tes=
ters to run KASAN builds on their daily devices. I would prefer even if we =
didn&#39;t ship in production, to at least have internal testers using this=
 build, as we have great panic reporting/collection.</div><div dir=3D"auto"=
><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
</blockquote></div></div></div>

--000000000000b088ae057046dc1f--
