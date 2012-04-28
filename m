Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F387F6B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 15:02:27 -0400 (EDT)
Received: by dadq36 with SMTP id q36so2492853dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 12:02:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120426162108.b654a920.akpm@linux-foundation.org>
References: <1335383992-19419-1-git-send-email-sasikanth.v19@gmail.com>
	<20120426162108.b654a920.akpm@linux-foundation.org>
Date: Sun, 29 Apr 2012 00:32:26 +0530
Message-ID: <CAOJFanUu_RD2UNgFg4gNuPte+jOA95ejMtq53UCo6vLaLohmQQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: memblock - Handled failure of debug fs entries creation
From: Sasikanth babu <sasikanth.v19@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b2e4f62a8228604bec1dcdf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--047d7b2e4f62a8228604bec1dcdf
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 27, 2012 at 4:51 AM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Thu, 26 Apr 2012 01:29:52 +0530
> Sasikantha babu <sasikanth.v19@gmail.com> wrote:
>
> > 1) Removed already created debug fs entries on failure
> >
> > 2) Fixed coding style 80 char per line
> >
> > Signed-off-by: Sasikantha babu <sasikanth.v19@gmail.com>
> > ---
> >  mm/memblock.c |   14 +++++++++++---
> >  1 files changed, 11 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index a44eab3..5553723 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -966,11 +966,19 @@ static int __init memblock_init_debugfs(void)
> >  {
> >       struct dentry *root = debugfs_create_dir("memblock", NULL);
> >       if (!root)
> > -             return -ENXIO;
> > -     debugfs_create_file("memory", S_IRUGO, root, &memblock.memory,
> &memblock_debug_fops);
> > -     debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved,
> &memblock_debug_fops);
> > +             return -ENOMEM;
>
> hm, why the switch to -ENOMEM?
>
>     Just for consistency (But its dumb mistake I made).


> Fact is, debugfs_create_dir() and debugfs_create_file() are stupid
> interfaces which don't provide the caller (and hence the user) with any
> information about why they failed.  Perhaps memblock_init_debugfs()
> should return -EWESUCK.
>

   I'm working on a patch which address this issue. debugfs_create_XXX
calls
   will return proper error codes, and fixing the existing code not each
and every part  but the code
   which handles the values returned by debufs_create_XXX otherwise it will
break the existing
   functionality . (any suggestions or opinions ?)
   .

Thanks
Sasi

>
> > +     if (!debugfs_create_file("memory", S_IRUGO, root, &memblock.memory,
> > +                             &memblock_debug_fops))
> > +             goto fail;
> > +     if (!debugfs_create_file("reserved", S_IRUGO, root,
> &memblock.reserved,
> > +                             &memblock_debug_fops))
> > +             goto fail;
> >
> >       return 0;
> > +fail:
> > +     debugfs_remove_recursive(root);
> > +     return -ENOMEM;
> >  }
> >  __initcall(memblock_init_debugfs);
>
>

--047d7b2e4f62a8228604bec1dcdf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote">On Fri, Apr 27, 2012 at 4:5=
1 AM, Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foun=
dation.org" target=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> wrot=
e:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">
<div class=3D"im">On Thu, 26 Apr 2012 01:29:52 +0530<br>
Sasikantha babu &lt;<a href=3D"mailto:sasikanth.v19@gmail.com">sasikanth.v1=
9@gmail.com</a>&gt; wrote:<br>
<br>
&gt; 1) Removed already created debug fs entries on failure<br>
&gt;<br>
&gt; 2) Fixed coding style 80 char per line<br>
&gt;<br>
&gt; Signed-off-by: Sasikantha babu &lt;<a href=3D"mailto:sasikanth.v19@gma=
il.com">sasikanth.v19@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/memblock.c | =A0 14 +++++++++++---<br>
&gt; =A01 files changed, 11 insertions(+), 3 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memblock.c b/mm/memblock.c<br>
&gt; index a44eab3..5553723 100644<br>
&gt; --- a/mm/memblock.c<br>
&gt; +++ b/mm/memblock.c<br>
&gt; @@ -966,11 +966,19 @@ static int __init memblock_init_debugfs(void)<br=
>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct dentry *root =3D debugfs_create_dir(&quot;memblock&=
quot;, NULL);<br>
&gt; =A0 =A0 =A0 if (!root)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return -ENXIO;<br>
&gt; - =A0 =A0 debugfs_create_file(&quot;memory&quot;, S_IRUGO, root, &amp;=
memblock.memory, &amp;memblock_debug_fops);<br>
&gt; - =A0 =A0 debugfs_create_file(&quot;reserved&quot;, S_IRUGO, root, &am=
p;memblock.reserved, &amp;memblock_debug_fops);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
<br>
</div>hm, why the switch to -ENOMEM?<br>
<br></blockquote><div>=A0 =A0 Just for consistency (But its dumb mistake I =
made).<br>=A0<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0p=
t 0pt 0pt 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
Fact is, debugfs_create_dir() and debugfs_create_file() are stupid<br>
interfaces which don&#39;t provide the caller (and hence the user) with any=
<br>
information about why they failed. =A0Perhaps memblock_init_debugfs()<br>
should return -EWESUCK.<br></blockquote><div>=A0=A0=A0 <br>=A0=A0 I&#39;m w=
orking on a patch which address this issue. debugfs_create_XXX=A0 calls<br>=
=A0=A0 will return proper error codes, and fixing the existing code not eac=
h and every part=A0 but the code<br>
=A0=A0 which handles the values returned by debufs_create_XXX otherwise it =
will break the existing <br>=A0=A0 functionality . (any suggestions or opin=
ions ?)<br>=A0=A0 .<br><br>Thanks<br>Sasi <br></div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0pt 0pt 0pt 0.8ex;border-left:1px solid rgb(204,=
204,204);padding-left:1ex">

<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; + =A0 =A0 if (!debugfs_create_file(&quot;memory&quot;, S_IRUGO, root, =
&amp;memblock.memory,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;membloc=
k_debug_fops))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
&gt; + =A0 =A0 if (!debugfs_create_file(&quot;reserved&quot;, S_IRUGO, root=
, &amp;memblock.reserved,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;membloc=
k_debug_fops))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto fail;<br>
&gt;<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; +fail:<br>
&gt; + =A0 =A0 debugfs_remove_recursive(root);<br>
&gt; + =A0 =A0 return -ENOMEM;<br>
&gt; =A0}<br>
&gt; =A0__initcall(memblock_init_debugfs);<br>
<br>
</div></div></blockquote></div><br></div>

--047d7b2e4f62a8228604bec1dcdf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
