Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A59C6B000A
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 10:52:00 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id s124-v6so7928036ybf.3
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 07:52:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z127-v6sor1487528ywf.36.2018.07.05.07.51.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 07:51:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3f7833bf-99ad-f36c-1e95-36bf78b60d50@nvidia.com>
References: <152938827880.17797.439879736804291936.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152938832086.17797.4538943238207602944.stgit@dwillia2-desk3.amr.corp.intel.com>
 <3f7833bf-99ad-f36c-1e95-36bf78b60d50@nvidia.com>
From: Joe Gorse <jhgorse@gmail.com>
Date: Thu, 5 Jul 2018 10:51:37 -0400
Message-ID: <CAFhSwD8KDQDEFiDUxJ5+iY8MtUqzgKEu+xMpRS4Nb8d3-TqADg@mail.gmail.com>
Subject: Re: [PATCH v3 8/8] mm: Fix exports that inadvertently make put_page() EXPORT_SYMBOL_GPL
Content-Type: multipart/alternative; boundary="00000000000068238e057041b0fb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--00000000000068238e057041b0fb
Content-Type: text/plain; charset="UTF-8"

Thank you! OpenAFS is good now as well.

In terms of schedule, when do you think this will make it upsteam? Will we
make the 4.18 kernel release?

Cheers,
Joe Gorse


On Tue, Jun 19, 2018 at 2:59 AM, John Hubbard <jhubbard@nvidia.com> wrote:

> On 06/18/2018 11:05 PM, Dan Williams wrote:
> > Now that all producers of dev_pagemap instances in the kernel are
> > properly converted to EXPORT_SYMBOL_GPL, fix up implicit consumers that
> > interact with dev_pagemap owners via put_page(). To reiterate,
> > dev_pagemap producers are EXPORT_SYMBOL_GPL because they adopt and
> > modify core memory management interfaces such that the dev_pagemap owner
> > can interact with all other kernel infrastructure and sub-systems
> > (drivers, filesystems, etc...) that consume page structures.
> >
> > Fixes: e76384884344 ("mm: introduce MEMORY_DEVICE_FS_DAX and
> CONFIG_DEV_PAGEMAP_OPS")
> > Reported-by: Joe Gorse <jhgorse@gmail.com>
> > Reported-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  kernel/memremap.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/kernel/memremap.c b/kernel/memremap.c
> > index 16141b608b63..ecee37b44aa1 100644
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -330,7 +330,7 @@ EXPORT_SYMBOL_GPL(get_dev_pagemap);
> >
> >  #ifdef CONFIG_DEV_PAGEMAP_OPS
> >  DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
> > -EXPORT_SYMBOL_GPL(devmap_managed_key);
> > +EXPORT_SYMBOL(devmap_managed_key);
> >  static atomic_t devmap_enable;
> >
> >  /*
> > @@ -371,5 +371,5 @@ void __put_devmap_managed_page(struct page *page)
> >       } else if (!count)
> >               __put_page(page);
> >  }
> > -EXPORT_SYMBOL_GPL(__put_devmap_managed_page);
> > +EXPORT_SYMBOL(__put_devmap_managed_page);
> >  #endif /* CONFIG_DEV_PAGEMAP_OPS */
> >
>
> Yep, that fixes everything I was seeing.
>
> thanks,
> --
> John Hubbard
> NVIDIA
>

--00000000000068238e057041b0fb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Thank you! OpenAFS is good now as well.</div><div><br=
></div><div>In terms of schedule, when do you think this will make it upste=
am? Will we make the 4.18 kernel release?</div><div><br></div><div>Cheers,<=
/div><div>Joe Gorse</div><div><br></div></div><div class=3D"gmail_extra"><b=
r><div class=3D"gmail_quote">On Tue, Jun 19, 2018 at 2:59 AM, John Hubbard =
<span dir=3D"ltr">&lt;<a href=3D"mailto:jhubbard@nvidia.com" target=3D"_bla=
nk">jhubbard@nvidia.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex"><div class=3D"HOEnZb"><div class=3D"h5">On 06/18/2018 11:05 PM, Dan Wi=
lliams wrote:<br>
&gt; Now that all producers of dev_pagemap instances in the kernel are<br>
&gt; properly converted to EXPORT_SYMBOL_GPL, fix up implicit consumers tha=
t<br>
&gt; interact with dev_pagemap owners via put_page(). To reiterate,<br>
&gt; dev_pagemap producers are EXPORT_SYMBOL_GPL because they adopt and<br>
&gt; modify core memory management interfaces such that the dev_pagemap own=
er<br>
&gt; can interact with all other kernel infrastructure and sub-systems<br>
&gt; (drivers, filesystems, etc...) that consume page structures.<br>
&gt; <br>
&gt; Fixes: e76384884344 (&quot;mm: introduce MEMORY_DEVICE_FS_DAX and CONF=
IG_DEV_PAGEMAP_OPS&quot;)<br>
&gt; Reported-by: Joe Gorse &lt;<a href=3D"mailto:jhgorse@gmail.com">jhgors=
e@gmail.com</a>&gt;<br>
&gt; Reported-by: John Hubbard &lt;<a href=3D"mailto:jhubbard@nvidia.com">j=
hubbard@nvidia.com</a>&gt;<br>
&gt; Signed-off-by: Dan Williams &lt;<a href=3D"mailto:dan.j.williams@intel=
.com">dan.j.williams@intel.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 kernel/memremap.c |=C2=A0 =C2=A0 4 ++--<br>
&gt;=C2=A0 1 file changed, 2 insertions(+), 2 deletions(-)<br>
&gt; <br>
&gt; diff --git a/kernel/memremap.c b/kernel/memremap.c<br>
&gt; index 16141b608b63..ecee37b44aa1 100644<br>
&gt; --- a/kernel/memremap.c<br>
&gt; +++ b/kernel/memremap.c<br>
&gt; @@ -330,7 +330,7 @@ EXPORT_SYMBOL_GPL(get_dev_<wbr>pagemap);<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 #ifdef CONFIG_DEV_PAGEMAP_OPS<br>
&gt;=C2=A0 DEFINE_STATIC_KEY_FALSE(<wbr>devmap_managed_key);<br>
&gt; -EXPORT_SYMBOL_GPL(devmap_<wbr>managed_key);<br>
&gt; +EXPORT_SYMBOL(devmap_managed_<wbr>key);<br>
&gt;=C2=A0 static atomic_t devmap_enable;<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 /*<br>
&gt; @@ -371,5 +371,5 @@ void __put_devmap_managed_page(<wbr>struct page *p=
age)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (!count)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__put_page(page)=
;<br>
&gt;=C2=A0 }<br>
&gt; -EXPORT_SYMBOL_GPL(__put_<wbr>devmap_managed_page);<br>
&gt; +EXPORT_SYMBOL(__put_devmap_<wbr>managed_page);<br>
&gt;=C2=A0 #endif /* CONFIG_DEV_PAGEMAP_OPS */<br>
&gt; <br>
<br>
</div></div>Yep, that fixes everything I was seeing.<br>
<br>
thanks,<br>
<span class=3D"HOEnZb"><font color=3D"#888888">-- <br>
John Hubbard<br>
NVIDIA<br>
</font></span></blockquote></div><br></div>

--00000000000068238e057041b0fb--
