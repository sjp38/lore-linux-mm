Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 07D2E800DA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 00:52:09 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id m8so1999102obr.36
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 21:52:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <BF30FAEC-D4D3-4079-9ECD-2743747279BD@cam.ac.uk>
References: <cover.1415220890.git.milosz@adfin.com>
	<c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com>
	<x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
	<BF30FAEC-D4D3-4079-9ECD-2743747279BD@cam.ac.uk>
Date: Thu, 6 Nov 2014 21:52:07 -0800
Message-ID: <CAFboF2y2skt=H4crv54shfnXOmz23W-shYWtHWekK8ZUDkfP=A@mail.gmail.com>
Subject: Re: [fuse-devel] [PATCH v5 7/7] add a flag for per-operation O_DSYNC semantics
From: Anand Avati <avati@gluster.org>
Content-Type: multipart/alternative; boundary=001a113df27ec1df0505073e690c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: Jeff Moyer <jmoyer@redhat.com>, linux-arch@vger.kernel.org, linux-aio@kvack.org, linux-nfs@vger.kernel.org, Volker Lendecke <Volker.Lendecke@sernet.de>, Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, "fuse-devel@lists.sourceforge.net" <fuse-devel@lists.sourceforge.net>, linux-api@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Tejun Heo <tj@kernel.org>, Milosz Tanski <milosz@adfin.com>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, ceph-devel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com, Mel Gorman <mgorman@suse.de>

--001a113df27ec1df0505073e690c
Content-Type: text/plain; charset=UTF-8

On Thu, Nov 6, 2014 at 8:22 PM, Anton Altaparmakov <aia21@cam.ac.uk> wrote:

> > On 7 Nov 2014, at 01:46, Jeff Moyer <jmoyer@redhat.com> wrote:
> > Minor nit, but I'd rather read something that looks like this:
> >
> >       if (type == READ && (flags & RWF_NONBLOCK))
> >               return -EAGAIN;
> >       else if (type == WRITE && (flags & RWF_DSYNC))
> >               return -EINVAL;
>
> But your version is less logically efficient for the case where "type ==
> READ" is true and "flags & RWF_NONBLOCK" is false because your version then
> has to do the "if (type == WRITE" check before discovering it does not need
> to take that branch either, whilst the original version does not have to do
> such a test at all.
>

Seriously? Just focus on the code readability/maintainability which makes
the code most easily understood/obvious to a new pair of eyes, and leave
such micro-optimizations to the compiler..

Thanks

--001a113df27ec1df0505073e690c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Thu, Nov 6, 2014 at 8:22 PM, Anton Altaparmakov <span dir=3D"ltr">&l=
t;<a href=3D"mailto:aia21@cam.ac.uk" target=3D"_blank">aia21@cam.ac.uk</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">&gt; On 7 Nov 2014, at =
01:46, Jeff Moyer &lt;<a href=3D"mailto:jmoyer@redhat.com">jmoyer@redhat.co=
m</a>&gt; wrote:<br>
&gt; Minor nit, but I&#39;d rather read something that looks like this:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (type =3D=3D READ &amp;&amp; (flags &amp;=
 RWF_NONBLOCK))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EAGAIN;<=
br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0else if (type =3D=3D WRITE &amp;&amp; (flags=
 &amp; RWF_DSYNC))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<=
br>
<br>
But your version is less logically efficient for the case where &quot;type =
=3D=3D READ&quot; is true and &quot;flags &amp; RWF_NONBLOCK&quot; is false=
 because your version then has to do the &quot;if (type =3D=3D WRITE&quot; =
check before discovering it does not need to take that branch either, whils=
t the original version does not have to do such a test at all.<br></blockqu=
ote><div><br></div><div>Seriously? Just focus on the code readability/maint=
ainability which makes the code most easily understood/obvious to a new pai=
r of eyes, and leave such micro-optimizations to the compiler..</div><div><=
br></div></div>Thanks</div></div>

--001a113df27ec1df0505073e690c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
