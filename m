Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C10B6B0260
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:20:17 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n4so90268447lfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:20:17 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id bp3si15638579wjc.217.2016.09.12.08.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 08:19:56 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id z194so1761685wmd.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:19:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160912113238.GA30927@amd>
References: <1473410612-6207-1-git-send-email-anisse@astier.eu> <20160912113238.GA30927@amd>
From: Anisse Astier <anisse@astier.eu>
Date: Mon, 12 Sep 2016 17:19:54 +0200
Message-ID: <CALUN=qJNX6HqrwXkk--8u0PiOxV-USE4tEouqimXPiRaobtAEw@mail.gmail.com>
Subject: Re: [PATCH] PM / Hibernate: allow hibernation with PAGE_POISONING_ZERO
Content-Type: multipart/alternative; boundary=089e0158c14848285d053c510717
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, linux-pm@vger.kernel.org, Mathias Krause <minipli@googlemail.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>, Jianyu Zhan <nasa4836@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Yves-Alexis Perez <corsac@debian.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Len Brown <len.brown@intel.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, PaX Team <pageexec@freemail.hu>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>

--089e0158c14848285d053c510717
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Le 12 sept. 2016 13:32, "Pavel Machek" <pavel@ucw.cz> a =C3=A9crit :
>
> On Fri 2016-09-09 10:43:32, Anisse Astier wrote:
> > PAGE_POISONING_ZERO disables zeroing new pages on alloc, they are
> > poisoned (zeroed) as they become available.
> > In the hibernate use case, free pages will appear in the system without
> > being cleared, left there by the loading kernel.
> >
> > This patch will make sure free pages are cleared on resume when
> > PAGE_POISONING_ZERO is enabled. We free the pages just after resume
> > because we can't do it later: going through any device resume code migh=
t
> > allocate some memory and invalidate the free pages bitmap.
> >
> > Thus we don't need to disable hibernation when PAGE_POISONING_ZERO is
> > enabled.
> >
> > Signed-off-by: Anisse Astier <anisse@astier.eu>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Laura Abbott <labbott@fedoraproject.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
>
> Looks reasonable to me.
>
> Acked-by: Pavel Machek <pavel@ucw.cz>
>
> Actually.... this takes basically zero time come. Do we want to do it
> unconditionally?
>
> (Yes, it is free memory, but for sake of debugging, I guess zeros are
> preffered to random content that changed during hibernation.)
>
> (But that does not change the Ack.)
>
> Best regards,
>
Pavel
> --

I have no opposition on doing this unconditionally. I can send a v2 as soon
as I get closer to a computer.

Regards,

Anisse

Sorry for the brevity, I'm posting this on mobile.

--089e0158c14848285d053c510717
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Le=C2=A012 sept. 2016 13:32, &quot;Pavel Machek&quot; &lt;<a=
 href=3D"mailto:pavel@ucw.cz">pavel@ucw.cz</a>&gt; a =C3=A9crit=C2=A0:<br>
&gt;<br>
&gt; On Fri 2016-09-09 10:43:32, Anisse Astier wrote:<br>
&gt; &gt; PAGE_POISONING_ZERO disables zeroing new pages on alloc, they are=
<br>
&gt; &gt; poisoned (zeroed) as they become available.<br>
&gt; &gt; In the hibernate use case, free pages will appear in the system w=
ithout<br>
&gt; &gt; being cleared, left there by the loading kernel.<br>
&gt; &gt;<br>
&gt; &gt; This patch will make sure free pages are cleared on resume when<b=
r>
&gt; &gt; PAGE_POISONING_ZERO is enabled. We free the pages just after resu=
me<br>
&gt; &gt; because we can&#39;t do it later: going through any device resume=
 code might<br>
&gt; &gt; allocate some memory and invalidate the free pages bitmap.<br>
&gt; &gt;<br>
&gt; &gt; Thus we don&#39;t need to disable hibernation when PAGE_POISONING=
_ZERO is<br>
&gt; &gt; enabled.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Anisse Astier &lt;<a href=3D"mailto:anisse@astier.=
eu">anisse@astier.eu</a>&gt;<br>
&gt; &gt; Cc: Kirill A. Shutemov &lt;<a href=3D"mailto:kirill.shutemov@linu=
x.intel.com">kirill.shutemov@linux.intel.com</a>&gt;<br>
&gt; &gt; Cc: Laura Abbott &lt;<a href=3D"mailto:labbott@fedoraproject.org"=
>labbott@fedoraproject.org</a>&gt;<br>
&gt; &gt; Cc: Mel Gorman &lt;<a href=3D"mailto:mgorman@suse.de">mgorman@sus=
e.de</a>&gt;<br>
&gt; &gt; Cc: Rafael J. Wysocki &lt;<a href=3D"mailto:rjw@rjwysocki.net">rj=
w@rjwysocki.net</a>&gt;<br>
&gt;<br>
&gt; Looks reasonable to me.<br>
&gt;<br>
&gt; Acked-by: Pavel Machek &lt;<a href=3D"mailto:pavel@ucw.cz">pavel@ucw.c=
z</a>&gt;<br>
&gt;<br>
&gt; Actually.... this takes basically zero time come. Do we want to do it<=
br>
&gt; unconditionally?<br>
&gt;<br>
&gt; (Yes, it is free memory, but for sake of debugging, I guess zeros are<=
br>
&gt; preffered to random content that changed during hibernation.)<br>
&gt;<br>
&gt; (But that does not change the Ack.)<br>
&gt;<br>
&gt; Best regards,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Pavel<br>
&gt; --</p>
<p dir=3D"ltr">I have no opposition on doing this unconditionally. I can se=
nd a v2 as soon as I get closer to a computer.</p>
<p dir=3D"ltr">Regards,</p>
<p dir=3D"ltr">Anisse</p>
<p dir=3D"ltr">Sorry for the brevity, I&#39;m posting this on mobile.</p>

--089e0158c14848285d053c510717--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
