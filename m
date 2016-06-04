Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD076B0253
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 21:10:22 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x85so81780162ioi.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 18:10:22 -0700 (PDT)
Received: from mail-oi0-x245.google.com (mail-oi0-x245.google.com. [2607:f8b0:4003:c06::245])
        by mx.google.com with ESMTPS id p24si3328257otp.241.2016.06.03.18.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 18:10:21 -0700 (PDT)
Received: by mail-oi0-x245.google.com with SMTP id s139so81070412oie.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 18:10:21 -0700 (PDT)
MIME-Version: 1.0
References: <1462713387-16724-1-git-send-email-anthony.romano@coreos.com> <5739B60E.1090700@suse.cz>
In-Reply-To: <5739B60E.1090700@suse.cz>
From: Brandon Philips <brandon@ifup.co>
Date: Sat, 04 Jun 2016 01:10:11 +0000
Message-ID: <CAEm7KtxBiDTsErPXUK32GbQF=9EAKtQJ7rM1oHR0WP304VvuBw@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: don't undo fallocate past its last page
Content-Type: multipart/alternative; boundary=001a1140f2ead7dcd9053469807d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anthony Romano <anthony.romano@coreos.com>, hughd@google.com, Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Kay Sievers <kay@vrfy.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Garrett <mjg59@srcf.ucam.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--001a1140f2ead7dcd9053469807d
Content-Type: text/plain; charset=UTF-8

On Mon, May 16, 2016 at 4:59 AM Vlastimil Babka <vbabka@suse.cz> wrote:

> On 05/08/2016 03:16 PM, Anthony Romano wrote:
> > When fallocate is interrupted it will undo a range that extends one byte
> > past its range of allocated pages. This can corrupt an in-use page by
> > zeroing out its first byte. Instead, undo using the inclusive byte range.
> > Signed-off-by: Anthony Romano <anthony.romano@coreos.com>
>
> Looks like a stable candidate patch. Can you point out the commit that
> introduced the bug, for the Fixes: tag?
>

Bumping this thread as I don't think this patch has gotten picked up. And
cc'ing folks from 1635f6a74152f1dcd1b888231609d64875f0a81a.

Thank you,

Brandon


> > ---
> >   mm/shmem.c | 2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 719bd6b..f0f9405 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, int
> mode, loff_t offset,
> >                       /* Remove the !PageUptodate pages we added */
> >                       shmem_undo_range(inode,
> >                               (loff_t)start << PAGE_SHIFT,
> > -                             (loff_t)index << PAGE_SHIFT, true);
> > +                             ((loff_t)index << PAGE_SHIFT) - 1, true);
> >                       goto undone;
> >               }
> >
> >
>
>

--001a1140f2ead7dcd9053469807d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><div dir=3D"ltr">On Mon, May 16=
, 2016 at 4:59 AM Vlastimil Babka &lt;<a href=3D"mailto:vbabka@suse.cz">vba=
bka@suse.cz</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On 05/08=
/2016 03:16 PM, Anthony Romano wrote:<br>
&gt; When fallocate is interrupted it will undo a range that extends one by=
te<br>
&gt; past its range of allocated pages. This can corrupt an in-use page by<=
br>
&gt; zeroing out its first byte. Instead, undo using the inclusive byte ran=
ge.<br>&gt; Signed-off-by: Anthony Romano &lt;<a href=3D"mailto:anthony.rom=
ano@coreos.com" target=3D"_blank">anthony.romano@coreos.com</a>&gt;<br>
<br>
Looks like a stable candidate patch. Can you point out the commit that<br>
introduced the bug, for the Fixes: tag?<br></blockquote><div><br></div><div=
>Bumping this thread as I don&#39;t think this patch has gotten picked up. =
And cc&#39;ing folks from 1635f6a74152f1dcd1b888231609d64875f0a81a.<br></di=
v><div><br></div><div>Thank you,</div><div><br></div><div><span style=3D"li=
ne-height:1.5">Brandon</span></div><div>=C2=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex">
&gt; ---<br>
&gt;=C2=A0 =C2=A0mm/shmem.c | 2 +-<br>
&gt;=C2=A0 =C2=A01 file changed, 1 insertion(+), 1 deletion(-)<br>
&gt;<br>
&gt; diff --git a/mm/shmem.c b/mm/shmem.c<br>
&gt; index 719bd6b..f0f9405 100644<br>
&gt; --- a/mm/shmem.c<br>
&gt; +++ b/mm/shmem.c<br>
&gt; @@ -2238,7 +2238,7 @@ static long shmem_fallocate(struct file *file, i=
nt mode, loff_t offset,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/* Remove the !PageUptodate pages we added */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0shmem_undo_range(inode,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(loff_t)start &lt;&lt; PAGE_SHIFT,=
<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(loff_t)index &lt;&lt; PAGE_SHIFT, true)=
;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0((loff_t)index &lt;&lt; PAGE_SHIFT) - 1,=
 true);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0goto undone;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt;<br>
<br>
</blockquote></div></div>

--001a1140f2ead7dcd9053469807d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
