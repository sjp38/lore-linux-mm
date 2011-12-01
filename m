Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EEFEA6B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 00:52:03 -0500 (EST)
Received: by mail-yx0-f175.google.com with SMTP id r11so1803656yen.34
        for <linux-mm@kvack.org>; Wed, 30 Nov 2011 21:51:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAF6AEGtgjjtVraeji09zKJSTmokmQqfk5S8LfHoMhHJY03dLkg@mail.gmail.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
 <1318325033-32688-2-git-send-email-sumit.semwal@ti.com> <CAPM=9tzjO7poyz_uYFFgONxzuTB86kKej8f2XBDHLGdUPZHvjg@mail.gmail.com>
 <CAPM=9txtWiQuF+jNZXDogCMy+nsM=00Bv3uxAiu5oKnn-KxjAA@mail.gmail.com>
 <CAKMK7uE14gOsTUYZknmSArkzG2zSSbpDeU0dxqAtLVUmvh-5bA@mail.gmail.com> <CAF6AEGtgjjtVraeji09zKJSTmokmQqfk5S8LfHoMhHJY03dLkg@mail.gmail.com>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Thu, 1 Dec 2011 11:21:38 +0530
Message-ID: <CAB2ybb9Ti-2iz_qDfzMSgDhpUc6UOtGS8wi52nQaxhB-gH=azg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
Content-Type: multipart/alternative; boundary=001636c9250b68968304b3017353
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, Dave Airlie <airlied@gmail.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org

--001636c9250b68968304b3017353
Content-Type: text/plain; charset=ISO-8859-1

Hi Dave, Daniel, Rob,

On Sun, Nov 27, 2011 at 12:29 PM, Rob Clark <robdclark@gmail.com> wrote:

> On Sat, Nov 26, 2011 at 8:00 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> > On Fri, Nov 25, 2011 at 17:28, Dave Airlie <airlied@gmail.com> wrote:
> >> I've rebuilt my PRIME interface on top of dmabuf to see how it would
> work,
> >>
> >> I've got primed gears running again on top, but I expect all my object
> >> lifetime and memory ownership rules need fixing up (i.e. leaks like a
> >> sieve).
> >>
> >> http://cgit.freedesktop.org/~airlied/linux/log/?h=drm-prime-dmabuf
> >>
> >> has the i915/nouveau patches for the kernel to produce the prime
> interface.
> >
> > I've noticed that your implementations for get_scatterlist (at least
> > for the i915 driver) doesn't return the sg table mapped into the
> > device address space. I've checked and the documentation makes it
> > clear that this should be the case (and we really need this to support
> > certain insane hw), but the get/put_scatterlist names are a bit
> > misleading. Proposal:
> >
> > - use struct sg_table instead of scatterlist like you've already done
> > in you branch. Simply more consistent with the dma api.
>
> yup
>
> > - rename get/put_scatterlist into map/unmap for consistency with all
> > the map/unmap dma api functions. The attachement would then serve as
> > the abstract cookie to the backing storage, similar to how struct page
> > * works as an abstract cookie for dma_map/unmap_page. The only special
> > thing is that struct device * parameter because that's already part of
> > the attachment.
>
> yup
>
> > - add new wrapper functions dma_buf_map_attachment and
> > dma_buf_unmap_attachement to hide all the pointer/vtable-chasing that
> > we currently expose to users of this interface.
>
> I thought that was one of the earlier comments on the initial dmabuf
> patch, but either way: yup
>
Thanks for your comments; I will incorporate all of these in the next
version I'll send out.

>
> BR,
> -R
>
BR,
Sumit.

>
> > Comments?
> >
> > Cheers, Daniel
> > --
> > Daniel Vetter
> > daniel.vetter@ffwll.ch - +41 (0) 79 364 57 48 - http://blog.ffwll.ch
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-media" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>

--001636c9250b68968304b3017353
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<font face=3D"courier new,monospace">Hi Dave, Daniel, Rob,</font><div><font=
 face=3D"courier new,monospace"><br></font></div><div><div class=3D"gmail_q=
uote">On Sun, Nov 27, 2011 at 12:29 PM, Rob Clark <span dir=3D"ltr">&lt;<a =
href=3D"mailto:robdclark@gmail.com">robdclark@gmail.com</a>&gt;</span> wrot=
e:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div class=3D"im">On Sat, Nov 26, 2011 at 8=
:00 AM, Daniel Vetter &lt;<a href=3D"mailto:daniel@ffwll.ch">daniel@ffwll.c=
h</a>&gt; wrote:<br>


&gt; On Fri, Nov 25, 2011 at 17:28, Dave Airlie &lt;<a href=3D"mailto:airli=
ed@gmail.com">airlied@gmail.com</a>&gt; wrote:<br>
&gt;&gt; I&#39;ve rebuilt my PRIME interface on top of dmabuf to see how it=
 would work,<br>
&gt;&gt;<br>
&gt;&gt; I&#39;ve got primed gears running again on top, but I expect all m=
y object<br>
&gt;&gt; lifetime and memory ownership rules need fixing up (i.e. leaks lik=
e a<br>
&gt;&gt; sieve).<br>
&gt;&gt;<br>
&gt;&gt; <a href=3D"http://cgit.freedesktop.org/~airlied/linux/log/?h=3Ddrm=
-prime-dmabuf" target=3D"_blank">http://cgit.freedesktop.org/~airlied/linux=
/log/?h=3Ddrm-prime-dmabuf</a><br>
&gt;&gt;<br>
&gt;&gt; has the i915/nouveau patches for the kernel to produce the prime i=
nterface.<br>
&gt;<br>
&gt; I&#39;ve noticed that your implementations for get_scatterlist (at lea=
st<br>
&gt; for the i915 driver) doesn&#39;t return the sg table mapped into the<b=
r>
&gt; device address space. I&#39;ve checked and the documentation makes it<=
br>
&gt; clear that this should be the case (and we really need this to support=
<br>
&gt; certain insane hw), but the get/put_scatterlist names are a bit<br>
&gt; misleading. Proposal:<br>
&gt;<br>
&gt; - use struct sg_table instead of scatterlist like you&#39;ve already d=
one<br>
&gt; in you branch. Simply more consistent with the dma api.<br>
<br>
</div>yup<br>
<div class=3D"im"><br>
&gt; - rename get/put_scatterlist into map/unmap for consistency with all<b=
r>
&gt; the map/unmap dma api functions. The attachement would then serve as<b=
r>
&gt; the abstract cookie to the backing storage, similar to how struct page=
<br>
&gt; * works as an abstract cookie for dma_map/unmap_page. The only special=
<br>
&gt; thing is that struct device * parameter because that&#39;s already par=
t of<br>
&gt; the attachment.<br>
<br>
</div>yup<br>
<div class=3D"im"><br>
&gt; - add new wrapper functions dma_buf_map_attachment and<br>
&gt; dma_buf_unmap_attachement to hide all the pointer/vtable-chasing that<=
br>
&gt; we currently expose to users of this interface.<br>
<br>
</div>I thought that was one of the earlier comments on the initial dmabuf<=
br>
patch, but either way: yup<br></blockquote><div>Thanks for your comments; I=
 will incorporate all of these in the next version I&#39;ll send out.=A0</d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex;">


<br>
BR,<br>
-R<br></blockquote><div>BR,</div><div>Sumit.=A0</div><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex;">
<div class=3D"im HOEnZb"><br>
&gt; Comments?<br>
&gt;<br>
&gt; Cheers, Daniel<br>
&gt; --<br>
&gt; Daniel Vetter<br>
&gt; <a href=3D"mailto:daniel.vetter@ffwll.ch">daniel.vetter@ffwll.ch</a> -=
 +41 (0) 79 364 57 48 - <a href=3D"http://blog.ffwll.ch" target=3D"_blank">=
http://blog.ffwll.ch</a><br>
</div><div class=3D"HOEnZb"><div class=3D"h5">&gt; --<br>
&gt; To unsubscribe from this list: send the line &quot;unsubscribe linux-m=
edia&quot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>
&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-=
info.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a>=
<br>
&gt;<br>
</div></div></blockquote></div><br></div>

--001636c9250b68968304b3017353--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
