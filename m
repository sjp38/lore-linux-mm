Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 943C96B0032
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 13:14:47 -0400 (EDT)
Received: by mail-vb0-f52.google.com with SMTP id f12so2409081vbg.11
        for <linux-mm@kvack.org>; Fri, 06 Sep 2013 10:14:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130906113358.6D8EEE0090@blue.fi.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-4-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2fJPngXwijEQcmVYB67u_4QDDJkpiyCv4K0iCFdmPsDuA@mail.gmail.com> <20130906113358.6D8EEE0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Fri, 6 Sep 2013 10:14:26 -0700
Message-ID: <CACz4_2eLe31NBVd+uhBjOGJRXy2xgS0kyEocWCnZcbHNuqs5Vw@mail.gmail.com>
Subject: Re: [PATCH 03/23] thp: compile-time and sysfs knob for thp pagecache
Content-Type: multipart/alternative; boundary=047d7b67317ee051a804e5ba2c06
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--047d7b67317ee051a804e5ba2c06
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Great!

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Fri, Sep 6, 2013 at 4:33 AM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> Ning Qu wrote:
> > One minor question inline.
> >
> > Best wishes,
> > --
> > Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | =
+1-408-418-6066
> >
> >
> > On Sat, Aug 3, 2013 at 7:17 PM, Kirill A. Shutemov <
> > kirill.shutemov@linux.intel.com> wrote:
> >
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > >
> > > For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for x86_6=
4.
> > >
> > > Radix tree perload overhead can be significant on BASE_SMALL systems,
> so
> > > let's add dependency on !BASE_SMALL.
> > >
> > > /sys/kernel/mm/transparent_hugepage/page_cache is runtime knob for th=
e
> > > feature. It's enabled by default if TRANSPARENT_HUGEPAGE_PAGECACHE is
> > > enabled.
> > >
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > ---
> > >  Documentation/vm/transhuge.txt |  9 +++++++++
> > >  include/linux/huge_mm.h        |  9 +++++++++
> > >  mm/Kconfig                     | 12 ++++++++++++
> > >  mm/huge_memory.c               | 23 +++++++++++++++++++++++
> > >  4 files changed, 53 insertions(+)
> > >
> > > diff --git a/Documentation/vm/transhuge.txt
> > > b/Documentation/vm/transhuge.txt
> > > index 4a63953..4cc15c4 100644
> > > --- a/Documentation/vm/transhuge.txt
> > > +++ b/Documentation/vm/transhuge.txt
> > > @@ -103,6 +103,15 @@ echo always
> > > >/sys/kernel/mm/transparent_hugepage/enabled
> > >  echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
> > >  echo never >/sys/kernel/mm/transparent_hugepage/enabled
> > >
> > > +If TRANSPARENT_HUGEPAGE_PAGECACHE is enabled kernel will use huge
> pages in
> > > +page cache if possible. It can be disable and re-enabled via sysfs:
> > > +
> > > +echo 0 >/sys/kernel/mm/transparent_hugepage/page_cache
> > > +echo 1 >/sys/kernel/mm/transparent_hugepage/page_cache
> > > +
> > > +If it's disabled kernel will not add new huge pages to page cache an=
d
> > > +split them on mapping, but already mapped pages will stay intakt.
> > > +
> > >  It's also possible to limit defrag efforts in the VM to generate
> > >  hugepages in case they're not immediately free to madvise regions or
> > >  to never try to defrag memory and simply fallback to regular pages
> > > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > > index 3935428..1534e1e 100644
> > > --- a/include/linux/huge_mm.h
> > > +++ b/include/linux/huge_mm.h
> > > @@ -40,6 +40,7 @@ enum transparent_hugepage_flag {
> > >         TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> > >         TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
> > >         TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
> > > +       TRANSPARENT_HUGEPAGE_PAGECACHE,
> > >         TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
> > >  #ifdef CONFIG_DEBUG_VM
> > >         TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
> > > @@ -229,4 +230,12 @@ static inline int do_huge_pmd_numa_page(struct
> > > mm_struct *mm, struct vm_area_str
> > >
> > >  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> > >
> > > +static inline bool transparent_hugepage_pagecache(void)
> > > +{
> > > +       if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
> > > +               return false;
> > > +       if (!(transparent_hugepage_flags &
> (1<<TRANSPARENT_HUGEPAGE_FLAG)))
> > >
> >
> > Here, I suppose we should test the  TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG =
as
> > well? E.g.
> >         if (!(transparent_hugepage_flags &
> >               ((1<<TRANSPARENT_HUGEPAGE_FLAG) |
> >                (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))))
> >
> > +               return false;
>
> You're right. Fixed.
>
> --
>  Kirill A. Shutemov
>

--047d7b67317ee051a804e5ba2c06
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Great!</div><div class=3D"gmail_extra"><br clear=3D"all"><=
div><div><div>Best wishes,<br></div><div><span style=3D"border-collapse:col=
lapse;font-family:arial,sans-serif;font-size:13px">--=C2=A0<br><span style=
=3D"border-collapse:collapse;font-family:sans-serif;line-height:19px"><span=
 style=3D"border-top-width:2px;border-right-width:0px;border-bottom-width:0=
px;border-left-width:0px;border-top-style:solid;border-right-style:solid;bo=
rder-bottom-style:solid;border-left-style:solid;border-top-color:rgb(213,15=
,37);border-right-color:rgb(213,15,37);border-bottom-color:rgb(213,15,37);b=
order-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Ning Qu (=
=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><span style=
=3D"color:rgb(85,85,85);border-top-width:2px;border-right-width:0px;border-=
bottom-width:0px;border-left-width:0px;border-top-style:solid;border-right-=
style:solid;border-bottom-style:solid;border-left-style:solid;border-top-co=
lor:rgb(51,105,232);border-right-color:rgb(51,105,232);border-bottom-color:=
rgb(51,105,232);border-left-color:rgb(51,105,232);padding-top:2px;margin-to=
p:2px">=C2=A0Software Engineer |</span><span style=3D"color:rgb(85,85,85);b=
order-top-width:2px;border-right-width:0px;border-bottom-width:0px;border-l=
eft-width:0px;border-top-style:solid;border-right-style:solid;border-bottom=
-style:solid;border-left-style:solid;border-top-color:rgb(0,153,57);border-=
right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border-left-col=
or:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailto:qu=
ning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">quning@goog=
le.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-top-width=
:2px;border-right-width:0px;border-bottom-width:0px;border-left-width:0px;b=
order-top-style:solid;border-right-style:solid;border-bottom-style:solid;bo=
rder-left-style:solid;border-top-color:rgb(238,178,17);border-right-color:r=
gb(238,178,17);border-bottom-color:rgb(238,178,17);border-left-color:rgb(23=
8,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502143877" s=
tyle=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></span></div>

</div></div>
<br><br><div class=3D"gmail_quote">On Fri, Sep 6, 2013 at 4:33 AM, Kirill A=
. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.in=
tel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> w=
rote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">Ning=
 Qu wrote:<br>
&gt; One minor question inline.<br>
&gt;<br>
&gt; Best wishes,<br>
&gt; --<br>
&gt; Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | <a href=3D"mailto:q=
uning@google.com">quning@google.com</a> | <a href=3D"tel:%2B1-408-418-6066"=
 value=3D"+14084186066">+1-408-418-6066</a><br>
&gt;<br>
&gt;<br>
&gt; On Sat, Aug 3, 2013 at 7:17 PM, Kirill A. Shutemov &lt;<br>
&gt; <a href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutemov@lin=
ux.intel.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; From: &quot;Kirill A. Shutemov&quot; &lt;<a href=3D"mailto:kirill=
.shutemov@linux.intel.com">kirill.shutemov@linux.intel.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for x=
86_64.<br>
&gt; &gt;<br>
&gt; &gt; Radix tree perload overhead can be significant on BASE_SMALL syst=
ems, so<br>
&gt; &gt; let&#39;s add dependency on !BASE_SMALL.<br>
&gt; &gt;<br>
&gt; &gt; /sys/kernel/mm/transparent_hugepage/page_cache is runtime knob fo=
r the<br>
&gt; &gt; feature. It&#39;s enabled by default if TRANSPARENT_HUGEPAGE_PAGE=
CACHE is<br>
&gt; &gt; enabled.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Kirill A. Shutemov &lt;<a href=3D"mailto:kirill.sh=
utemov@linux.intel.com">kirill.shutemov@linux.intel.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =C2=A0Documentation/vm/transhuge.txt | =C2=A09 +++++++++<br>
&gt; &gt; =C2=A0include/linux/huge_mm.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
9 +++++++++<br>
&gt; &gt; =C2=A0mm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | 12 ++++++++++++<br>
&gt; &gt; =C2=A0mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | 23 +++++++++++++++++++++++<br>
&gt; &gt; =C2=A04 files changed, 53 insertions(+)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/Documentation/vm/transhuge.txt<br>
&gt; &gt; b/Documentation/vm/transhuge.txt<br>
&gt; &gt; index 4a63953..4cc15c4 100644<br>
&gt; &gt; --- a/Documentation/vm/transhuge.txt<br>
&gt; &gt; +++ b/Documentation/vm/transhuge.txt<br>
&gt; &gt; @@ -103,6 +103,15 @@ echo always<br>
&gt; &gt; &gt;/sys/kernel/mm/transparent_hugepage/enabled<br>
&gt; &gt; =C2=A0echo madvise &gt;/sys/kernel/mm/transparent_hugepage/enable=
d<br>
&gt; &gt; =C2=A0echo never &gt;/sys/kernel/mm/transparent_hugepage/enabled<=
br>
&gt; &gt;<br>
&gt; &gt; +If TRANSPARENT_HUGEPAGE_PAGECACHE is enabled kernel will use hug=
e pages in<br>
&gt; &gt; +page cache if possible. It can be disable and re-enabled via sys=
fs:<br>
&gt; &gt; +<br>
&gt; &gt; +echo 0 &gt;/sys/kernel/mm/transparent_hugepage/page_cache<br>
&gt; &gt; +echo 1 &gt;/sys/kernel/mm/transparent_hugepage/page_cache<br>
&gt; &gt; +<br>
&gt; &gt; +If it&#39;s disabled kernel will not add new huge pages to page =
cache and<br>
&gt; &gt; +split them on mapping, but already mapped pages will stay intakt=
.<br>
&gt; &gt; +<br>
&gt; &gt; =C2=A0It&#39;s also possible to limit defrag efforts in the VM to=
 generate<br>
&gt; &gt; =C2=A0hugepages in case they&#39;re not immediately free to madvi=
se regions or<br>
&gt; &gt; =C2=A0to never try to defrag memory and simply fallback to regula=
r pages<br>
&gt; &gt; diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h<br=
>
&gt; &gt; index 3935428..1534e1e 100644<br>
&gt; &gt; --- a/include/linux/huge_mm.h<br>
&gt; &gt; +++ b/include/linux/huge_mm.h<br>
&gt; &gt; @@ -40,6 +40,7 @@ enum transparent_hugepage_flag {<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_=
FLAG,<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGE=
D_FLAG,<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_PAGECACHE,<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FL=
AG,<br>
&gt; &gt; =C2=A0#ifdef CONFIG_DEBUG_VM<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,<=
br>
&gt; &gt; @@ -229,4 +230,12 @@ static inline int do_huge_pmd_numa_page(stru=
ct<br>
&gt; &gt; mm_struct *mm, struct vm_area_str<br>
&gt; &gt;<br>
&gt; &gt; =C2=A0#endif /* CONFIG_TRANSPARENT_HUGEPAGE */<br>
&gt; &gt;<br>
&gt; &gt; +static inline bool transparent_hugepage_pagecache(void)<br>
&gt; &gt; +{<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAG=
E_PAGECACHE))<br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<=
br>
&gt; &gt; + =C2=A0 =C2=A0 =C2=A0 if (!(transparent_hugepage_flags &amp; (1&=
lt;&lt;TRANSPARENT_HUGEPAGE_FLAG)))<br>
&gt; &gt;<br>
&gt;<br>
&gt; Here, I suppose we should test the =C2=A0TRANSPARENT_HUGEPAGE_REQ_MADV=
_FLAG as<br>
&gt; well? E.g.<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(transparent_hugepage_flags &amp;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((1&lt;&lt;TRANSPAREN=
T_HUGEPAGE_FLAG) |<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(1&lt;&lt;TRANS=
PARENT_HUGEPAGE_REQ_MADV_FLAG))))<br>
&gt;<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;<br>
<br>
</div></div>You&#39;re right. Fixed.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br></div>

--047d7b67317ee051a804e5ba2c06--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
