Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 699196B025F
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 12:17:31 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id g129so17100426ywh.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:17:31 -0700 (PDT)
Received: from mail-yw0-x231.google.com (mail-yw0-x231.google.com. [2607:f8b0:4002:c05::231])
        by mx.google.com with ESMTPS id r207si1990189ywg.648.2017.08.10.09.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 09:17:30 -0700 (PDT)
Received: by mail-yw0-x231.google.com with SMTP id s143so7705580ywg.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 09:17:30 -0700 (PDT)
MIME-Version: 1.0
References: <20170806140425.20937-1-riel@redhat.com> <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz> <1502117991.6577.13.camel@redhat.com>
 <20170810130531.GS23863@dhcp22.suse.cz> <CAAF6GDc2hsj-XJj=Rx2ZF6Sh3Ke6nKewABXfqQxQjfDd5QN7Ug@mail.gmail.com>
 <20170810153639.GB23863@dhcp22.suse.cz>
In-Reply-To: <20170810153639.GB23863@dhcp22.suse.cz>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Thu, 10 Aug 2017 16:17:18 +0000
Message-ID: <CAAF6GDeno6RpHf1KORVSxUL7M-CQfbWFFdyKK8LAWd_6PcJ55Q@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Content-Type: multipart/alternative; boundary="001a11470cb07b0d5605566888e2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Rik van Riel <riel@redhat.com>, Will Drewry <wad@chromium.org>, akpm@linux-foundation.org, dave.hansen@intel.com, kirill@shutemov.name, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@amacapital.net, mingo@kernel.org

--001a11470cb07b0d5605566888e2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On D=C3=A9ar 10 L=C3=BAn 2017 at 17:36 Michal Hocko <mhocko@kernel.org> wro=
te:

> On Thu 10-08-17 15:23:05, Colm MacC=C4=AFrthaigh wrote:
> > On Thu, Aug 10, 2017 at 3:05 PM, Michal Hocko <mhocko@kernel.org> wrote=
:
> > >> Too late for that. VM_DONTFORK is already implemented
> > >> through MADV_DONTFORK & MADV_DOFORK, in a way that is
> > >> very similar to the MADV_WIPEONFORK from these patches.
> > >
> > > Yeah, those two seem to be breaking the "madvise as an advise"
> semantic as
> > > well but that doesn't mean we should follow that pattern any further.
> >
> > I would imagine that many of the crypto applications using
> > MADV_WIPEONFORK will also be using MADV_DONTDUMP. In cases where it's
> > for protecting secret keys, I'd like to use both in my code, for
> > example. Though that doesn't really help decide this.
> >
> > There is also at least one case for being able to turn WIPEONFORK
> > on/off with an existing page; a process that uses privilege separation
> > often goes through the following flow:
> >
> > 1. [ Access privileged keys as a power user and initialize memory ]
> > 2. [ Fork a child process that actually does the work ]
> > 3. [ Child drops privileges and uses the memory to do work ]
> > 4. [ Parent hangs around to re-spawn a child if it crashes ]
> >
> > In that mode it would be convenient to be able to mark the memory as
> > WIPEONFORK in the child, but not the parent.
>
> I am not sure I understand. The child will have an own VMA so chaging
> the attribute will not affect parent. Or did I misunderstand your
> example?
>

Typically with privilege separation the parent has to share some minimal
state with the child. In this case that's why the page is left alone.
Though a smart parent could unset and set just immediately around the fork.

The point then of protecting it in the child is to ensure that a grandchild
doesn't inherit the secret data.

--=20
Colm

--001a11470cb07b0d5605566888e2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><div class=3D"gmail_quote"><div dir=3D"auto">On D=C3=A9ar 10 L=C3=BAn 2=
017 at 17:36 Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org">mhocko@k=
ernel.org</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Thu 1=
0-08-17 15:23:05, Colm MacC=C4=AFrthaigh wrote:<br>
&gt; On Thu, Aug 10, 2017 at 3:05 PM, Michal Hocko &lt;<a href=3D"mailto:mh=
ocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt; wrote:<br>
&gt; &gt;&gt; Too late for that. VM_DONTFORK is already implemented<br>
&gt; &gt;&gt; through MADV_DONTFORK &amp; MADV_DOFORK, in a way that is<br>
&gt; &gt;&gt; very similar to the MADV_WIPEONFORK from these patches.<br>
&gt; &gt;<br>
&gt; &gt; Yeah, those two seem to be breaking the &quot;madvise as an advis=
e&quot; semantic as<br>
&gt; &gt; well but that doesn&#39;t mean we should follow that pattern any =
further.<br>
&gt;<br>
&gt; I would imagine that many of the crypto applications using<br>
&gt; MADV_WIPEONFORK will also be using MADV_DONTDUMP. In cases where it&#3=
9;s<br>
&gt; for protecting secret keys, I&#39;d like to use both in my code, for<b=
r>
&gt; example. Though that doesn&#39;t really help decide this.<br>
&gt;<br>
&gt; There is also at least one case for being able to turn WIPEONFORK<br>
&gt; on/off with an existing page; a process that uses privilege separation=
<br>
&gt; often goes through the following flow:<br>
&gt;<br>
&gt; 1. [ Access privileged keys as a power user and initialize memory ]<br=
>
&gt; 2. [ Fork a child process that actually does the work ]<br>
&gt; 3. [ Child drops privileges and uses the memory to do work ]<br>
&gt; 4. [ Parent hangs around to re-spawn a child if it crashes ]<br>
&gt;<br>
&gt; In that mode it would be convenient to be able to mark the memory as<b=
r>
&gt; WIPEONFORK in the child, but not the parent.<br>
<br>
I am not sure I understand. The child will have an own VMA so chaging<br>
the attribute will not affect parent. Or did I misunderstand your<br>
example?<br>
</blockquote><div dir=3D"auto"><br></div><div dir=3D"auto">Typically with p=
rivilege separation the parent has to share some minimal state with the chi=
ld. In this case that&#39;s why the page is left alone. Though a smart pare=
nt could unset and set just immediately around the fork.=C2=A0</div><div di=
r=3D"auto"><br></div><div dir=3D"auto">The point then of protecting it in t=
he child is to ensure that a grandchild doesn&#39;t inherit the secret data=
.</div><div dir=3D"auto"><br></div></div><div dir=3D"ltr">-- <br></div><div=
 class=3D"gmail_signature" data-smartmail=3D"gmail_signature">Colm</div>

--001a11470cb07b0d5605566888e2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
