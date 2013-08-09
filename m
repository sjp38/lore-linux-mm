Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id F37736B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 10:49:24 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id q14so4091038vbe.41
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 07:49:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130809144601.159CAE0090@blue.fi.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1375582645-29274-21-git-send-email-kirill.shutemov@linux.intel.com>
	<CACz4_2f2frTktfUusWGcaqZtTmQS8FSY0HqwXCas44EW7Q5Xsw@mail.gmail.com>
	<CACz4_2de=zm2-VtE=dFTfYjrdma4QFX1S-ukQ_7J4DZ32q1JQQ@mail.gmail.com>
	<CACz4_2fv1g2dRLh72gtaCYkNC6+Pp4h=R0q-taR51tejpL1gnw@mail.gmail.com>
	<20130809144601.159CAE0090@blue.fi.intel.com>
Date: Fri, 9 Aug 2013 07:49:23 -0700
Message-ID: <CACz4_2cMSn1_DhVjN1ch60XDMSw1OxHjM+zh=+-iBtejgpHk8g@mail.gmail.com>
Subject: Re: [PATCH 20/23] thp: handle file pages in split_huge_page()
From: Ning Qu <quning@google.com>
Content-Type: multipart/alternative; boundary=001a11339c6c68499904e384e1b8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

--001a11339c6c68499904e384e1b8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Sure!
On Aug 9, 2013 7:42 AM, "Kirill A. Shutemov" <
kirill.shutemov@linux.intel.com> wrote:

> Ning Qu wrote:
> > I just tried, and it seems working fine now without the deadlock
> anymore. I
> > can run some big internal test with about 40GB files in sysv shm. Just
> move
> > the line before the locking happens in vma_adjust, something as below,
> the
> > line number is not accurate because my patch is based on another tree
> right
> > now.
>
> Looks okay to me. Could you prepare real patch (description, etc.). I'll
> add it to my patchset.
>
> >
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -581,6 +581,8 @@ again:                      remove_next =3D 1 + (en=
d >
> > next->vm_end);
> >                 }
> >         }
> >
> > +       vma_adjust_trans_huge(vma, start, end, adjust_next);
> > +
> >         if (file) {
> >                 mapping =3D file->f_mapping;
> >                 if (!(vma->vm_flags & VM_NONLINEAR))
> > @@ -597,8 +599,6 @@ again:                      remove_next =3D 1 + (en=
d >
> > next->vm_end);
> >                 }
> >         }
> >
> > -       vma_adjust_trans_huge(vma, start, end, adjust_next);
> > -
> >         anon_vma =3D vma->anon_vma;
> >         if (!anon_vma && adjust_next)
> >                 anon_vma =3D next->anon_vma;
> >
> >
> > Best wishes,
> > --
> > Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | =
+1-408-418-6066
>
> --
>  Kirill A. Shutemov
>

--001a11339c6c68499904e384e1b8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Sure! </p>
<div class=3D"gmail_quote">On Aug 9, 2013 7:42 AM, &quot;Kirill A. Shutemov=
&quot; &lt;<a href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutem=
ov@linux.intel.com</a>&gt; wrote:<br type=3D"attribution"><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
Ning Qu wrote:<br>
&gt; I just tried, and it seems working fine now without the deadlock anymo=
re. I<br>
&gt; can run some big internal test with about 40GB files in sysv shm. Just=
 move<br>
&gt; the line before the locking happens in vma_adjust, something as below,=
 the<br>
&gt; line number is not accurate because my patch is based on another tree =
right<br>
&gt; now.<br>
<br>
Looks okay to me. Could you prepare real patch (description, etc.). I&#39;l=
l<br>
add it to my patchset.<br>
<br>
&gt;<br>
&gt; --- a/mm/mmap.c<br>
&gt; +++ b/mm/mmap.c<br>
&gt; @@ -581,6 +581,8 @@ again: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_next =3D 1 + (end &gt;<br>
&gt; next-&gt;vm_end);<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
&gt;<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 vma_adjust_trans_huge(vma, start, end, adjust_n=
ext);<br>
&gt; +<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (file) {<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapping =3D fi=
le-&gt;f_mapping;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(vma-&gt;=
vm_flags &amp; VM_NONLINEAR))<br>
&gt; @@ -597,8 +599,6 @@ again: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_next =3D 1 + (end &gt;<br>
&gt; next-&gt;vm_end);<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
&gt;<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 vma_adjust_trans_huge(vma, start, end, adjust_n=
ext);<br>
&gt; -<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D vma-&gt;anon_vma;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!anon_vma &amp;&amp; adjust_next)<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D n=
ext-&gt;anon_vma;<br>
&gt;<br>
&gt;<br>
&gt; Best wishes,<br>
&gt; --<br>
&gt; Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | <a href=3D"mailto:q=
uning@google.com">quning@google.com</a> | <a href=3D"tel:%2B1-408-418-6066"=
 value=3D"+14084186066">+1-408-418-6066</a><br>
<br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</blockquote></div>

--001a11339c6c68499904e384e1b8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
