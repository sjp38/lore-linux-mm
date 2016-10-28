Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 888046B028B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 18:25:17 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 51so47577887uai.3
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 15:25:17 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id 92si7375849uaw.220.2016.10.28.15.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 15:25:16 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id 23so2465963qtp.2
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 15:25:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161028145215.87fd39d8f8822a2cd11b621c@linux-foundation.org>
References: <bug-180101-27@https.bugzilla.kernel.org/> <20161028145215.87fd39d8f8822a2cd11b621c@linux-foundation.org>
From: Joseph Yasi <joe.yasi@gmail.com>
Date: Fri, 28 Oct 2016 18:25:15 -0400
Message-ID: <CADzA9onJOyKGWkzzr7HP742-xXpiJciNddhv946Yg_tPSszTDQ@mail.gmail.com>
Subject: Re: [Bug 180101] New: BUG: unable to handle kernel paging request at
 x with "mm: remove gup_flags FOLL_WRITE games from __get_user_pages()"
Content-Type: multipart/alternative; boundary=001a114069a42139de053ff4554e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

--001a114069a42139de053ff4554e
Content-Type: text/plain; charset=UTF-8

On Fri, Oct 28, 2016 at 5:52 PM, Andrew Morton <akpm@linux-foundation.org>
wrote:

>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Mon, 24 Oct 2016 01:27:15 +0000 bugzilla-daemon@bugzilla.kernel.org
> wrote:
>
> > https://bugzilla.kernel.org/show_bug.cgi?id=180101
> >
> >             Bug ID: 180101
> >            Summary: BUG: unable to handle kernel paging request at x with
> >                     "mm: remove gup_flags FOLL_WRITE games from
> >                     __get_user_pages()"
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.8.4
> >           Hardware: x86-64
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: joe.yasi@gmail.com
> >         Regression: No
> >
> > After updating to 4.8.3 and 4.8.4, I am having stability issues. I can
> also
> > reproduce them with 4.7.10. This issue does not occur with 4.8.2. I can
> also
> > not reproduce after reverting the security fix
> > 89eeba1594ac641a30b91942961e80fae978f839 "mm: remove gup_flags
> FOLL_WRITE games
> > from __get_user_pages()" with 4.8.4.
>
> That's 19be0eaffa3ac7d8eb ("mm: remove gup_flags FOLL_WRITE games from
> __get_user_pages()") in the upstream tree.
>
> I seem to recall a fix for that patch went flying past earlier this
> week.  Perhaps Linus recalls?
>
> 19be0eaffa3ac7d8eb has gone into a billion -stable trees so we'll need
> to be attentive...
>
>
I've been able to reproduce the issue with 19be0eaffa3ac7d8eb ("mm: remove
gup_flags FOLL_WRITE games from __get_user_pages()") reverted. I initially
suspected it because I hadn't seen the issue until 4.8.3, and also saw it
when I tried 4.7.10. Initially, I wasn't able to reproduce it with 4.8.2,
but I've since been able to do that. This smells like a race condition
somewhere. It's possible I just happened to never encounter that race
before.

The /home partition in question is btrfs on bcache in writethrough mode.
The cache drive is an 180 GB Intel SATA SSD, and the backing device is two
WD 3 TB SATA HDDs configured in MD RAID 10 f2 layout. / is btrfs on an NVMe
SSD.

I've also seen btrfs checksum errors in the kernel log when reproducing
this. Rebooting and running btrfs scrub finds nothing though so it seems
like in memory corruption.

Thanks,
Joe

--001a114069a42139de053ff4554e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Fri, Oct 28, 2016 at 5:52 PM, Andrew Morton <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundat=
ion.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D=
"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-le=
ft:1ex"><br>
(switched to email.=C2=A0 Please respond via emailed reply-to-all, not via =
the<br>
bugzilla web interface).<br>
<br>
On Mon, 24 Oct 2016 01:27:15 +0000 <a href=3D"mailto:bugzilla-daemon@bugzil=
la.kernel.org">bugzilla-daemon@bugzilla.<wbr>kernel.org</a> wrote:<br>
<br>
&gt; <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D180101" rel=
=3D"noreferrer" target=3D"_blank">https://bugzilla.kernel.org/<wbr>show_bug=
.cgi?id=3D180101</a><br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Bug ID: 180101<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Summary: BUG: unable to handl=
e kernel paging request at x with<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0&quot;mm: remove gup_flags FOLL_WRITE games from<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0__get_user_pages()&quot;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Product: Memory Management<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Version: 2.5<br>
&gt;=C2=A0 =C2=A0 =C2=A0Kernel Version: 4.8.4<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Hardware: x86-64<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0OS: Linux=
<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Tree: Mainline<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Status: NEW<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Severity: high<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Priority: P1<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Component: Other<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Assignee: <a href=3D"mailto:ak=
pm@linux-foundation.org">akpm@linux-foundation.org</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Reporter: <a href=3D"mailto:jo=
e.yasi@gmail.com">joe.yasi@gmail.com</a><br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Regression: No<br>
&gt;<br>
&gt; After updating to 4.8.3 and 4.8.4, I am having stability issues. I can=
 also<br>
&gt; reproduce them with 4.7.10. This issue does not occur with 4.8.2. I ca=
n also<br>
&gt; not reproduce after reverting the security fix<br>
&gt; 89eeba1594ac641a30b91942961e80<wbr>fae978f839 &quot;mm: remove gup_fla=
gs FOLL_WRITE games<br>
&gt; from __get_user_pages()&quot; with 4.8.4.<br>
<br>
That&#39;s 19be0eaffa3ac7d8eb (&quot;mm: remove gup_flags FOLL_WRITE games =
from<br>
__get_user_pages()&quot;) in the upstream tree.<br>
<br>
I seem to recall a fix for that patch went flying past earlier this<br>
week.=C2=A0 Perhaps Linus recalls?<br>
<br>
19be0eaffa3ac7d8eb has gone into a billion -stable trees so we&#39;ll need<=
br>
to be attentive...<br>
<br></blockquote><div><br></div><div>I&#39;ve been able to reproduce the is=
sue with 19be0eaffa3ac7d8eb (&quot;mm: remove gup_flags FOLL_WRITE games fr=
om __get_user_pages()&quot;) reverted. I initially suspected it because I h=
adn&#39;t seen the issue until 4.8.3, and also saw it when I tried 4.7.10. =
Initially, I wasn&#39;t able to reproduce it with 4.8.2, but I&#39;ve since=
 been able to do that. This smells like a race condition somewhere. It&#39;=
s possible I just happened to never encounter that race before.</div><div><=
br></div><div>The /home partition in question is btrfs on bcache in writeth=
rough mode. The cache drive is an 180 GB Intel SATA SSD, and the backing de=
vice is two WD 3 TB SATA HDDs configured in MD RAID 10 f2 layout. / is btrf=
s on an NVMe SSD.</div><div><br></div><div>I&#39;ve also seen btrfs checksu=
m errors in the kernel log when reproducing this. Rebooting and running btr=
fs scrub finds nothing though so it seems like in memory corruption.</div><=
div><br></div><div>Thanks,</div><div>Joe</div></div></div></div>

--001a114069a42139de053ff4554e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
