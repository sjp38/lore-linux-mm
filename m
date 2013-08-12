Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6CDDA6B0037
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 12:43:24 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id fj20so4954490lab.18
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:43:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130812135509.DDF5FE0090@blue.fi.intel.com>
References: <93894D4C-57FA-46B5-9141-4EFADEB7009E@gmail.com> <20130812135509.DDF5FE0090@blue.fi.intel.com>
From: Ning Qu <quning@gmail.com>
Date: Mon, 12 Aug 2013 09:42:42 -0700
Message-ID: <CACQD4-5Aie7c=QTVgWkf76fEsWOuR52PZHi0YLfrqdbX5bY03w@mail.gmail.com>
Subject: Re: [PATCH] thp: Fix deadlock situation in vma_adjust with huge page
 in page cache
Content-Type: multipart/alternative; boundary=001a11336b3e8c0a9f04e3c2d2de
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

--001a11336b3e8c0a9f04e3c2d2de
Content-Type: text/plain; charset=UTF-8

That's great!

Best wishes,
-- 
Ning Qu


On Mon, Aug 12, 2013 at 6:55 AM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> Ning Qu wrote:
> > In vma_adjust, the current code grabs i_mmap_mutex before calling
> > vma_adjust_trans_huge. This used to be fine until huge page in page
> > cache comes in. The problem is the underlying function
> > split_file_huge_page will also grab the i_mmap_mutex before splitting
> > the huge page in page cache. Obviously this is causing deadlock
> > situation.
> >
> > This fix is to move the vma_adjust_trans_huge before grab the lock for
> > file, the same as what the function is currently doing for anonymous
> > memory.
> >
> > Tested, everything works fine so far.
> >
> > Signed-off-by: Ning Qu <quning@google.com>
>
> Thanks, applied.
>
> --
>  Kirill A. Shutemov
>

--001a11336b3e8c0a9f04e3c2d2de
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">That&#39;s great!</div><div class=3D"gmail_extra"><br clea=
r=3D"all"><div><div dir=3D"ltr">Best wishes,<br>--=C2=A0<br>Ning Qu</div></=
div>
<br><br><div class=3D"gmail_quote">On Mon, Aug 12, 2013 at 6:55 AM, Kirill =
A. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.i=
ntel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> =
wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">Ning Qu wrote:<br>
&gt; In vma_adjust, the current code grabs i_mmap_mutex before calling<br>
&gt; vma_adjust_trans_huge. This used to be fine until huge page in page<br=
>
&gt; cache comes in. The problem is the underlying function<br>
&gt; split_file_huge_page will also grab the i_mmap_mutex before splitting<=
br>
&gt; the huge page in page cache. Obviously this is causing deadlock<br>
&gt; situation.<br>
&gt;<br>
&gt; This fix is to move the vma_adjust_trans_huge before grab the lock for=
<br>
&gt; file, the same as what the function is currently doing for anonymous<b=
r>
&gt; memory.<br>
&gt;<br>
&gt; Tested, everything works fine so far.<br>
&gt;<br>
&gt; Signed-off-by: Ning Qu &lt;<a href=3D"mailto:quning@google.com">quning=
@google.com</a>&gt;<br>
<br>
</div>Thanks, applied.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br></div>

--001a11336b3e8c0a9f04e3c2d2de--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
