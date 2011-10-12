Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A82DC6B016A
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 08:41:59 -0400 (EDT)
Received: by ywe9 with SMTP id 9so844883ywe.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 05:41:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
Date: Wed, 12 Oct 2011 13:41:57 +0100
Message-ID: <CAPM=9tzHOa5Dbe=SQz+AURMMbio4L7qoS8kUT3Ek0+HdtkrH4g@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch

On Tue, Oct 11, 2011 at 10:23 AM, Sumit Semwal <sumit.semwal@ti.com> wrote:
> This is the first step in defining a dma buffer sharing mechanism.
>
> A new buffer object dma_buf is added, with operations and API to allow ea=
sy
> sharing of this buffer object across devices.
>
> The framework allows:
> - a new buffer-object to be created with fixed size.
> - different devices to 'attach' themselves to this buffer, to facilitate
> =A0backing storage negotiation, using dma_buf_attach() API.
> - association of a file pointer with each user-buffer and associated
> =A0 allocator-defined operations on that buffer. This operation is called=
 the
> =A0 'export' operation.
> - this exported buffer-object to be shared with the other entity by askin=
g for
> =A0 its 'file-descriptor (fd)', and sharing the fd across.
> - a received fd to get the buffer object back, where it can be accessed u=
sing
> =A0 the associated exporter-defined operations.
> - the exporter and user to share the scatterlist using get_scatterlist an=
d
> =A0 put_scatterlist operations.
>
> Atleast one 'attach()' call is required to be made prior to calling the
> get_scatterlist() operation.
>
> Couple of building blocks in get_scatterlist() are added to ease introduc=
tion
> of sync'ing across exporter and users, and late allocation by the exporte=
r.
>
> mmap() file operation is provided for the associated 'fd', as wrapper ove=
r the
> optional allocator defined mmap(), to be used by devices that might need =
one.

Why is this needed? it really doesn't make sense to be mmaping objects
independent of some front-end like drm or v4l.

how will you know what contents are in them, how will you synchronise
access. Unless someone has a hard use-case for this I'd say we drop it
until someone does.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
