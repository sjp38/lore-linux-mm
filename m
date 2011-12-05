Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 8D5086B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 17:33:37 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2277403vbb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 14:33:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAF6AEGto-+oSqguuWyPunUbtE65GpNiXh21srQzrChiBQMb1Nw@mail.gmail.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<1322816252-19955-2-git-send-email-sumit.semwal@ti.com>
	<201112051718.48324.arnd@arndb.de>
	<CAF6AEGvyWV0DM2fjBbh-TNHiMmiLF4EQDJ6Uu0=NkopM6SXS6g@mail.gmail.com>
	<CAKMK7uHw3OpMAtVib=e=s_us9Tx9TebzehGg59d4-g9dUXr+pQ@mail.gmail.com>
	<CAF6AEGto-+oSqguuWyPunUbtE65GpNiXh21srQzrChiBQMb1Nw@mail.gmail.com>
Date: Mon, 5 Dec 2011 23:33:36 +0100
Message-ID: <CAKMK7uFpQfAkoEqAJc8hX6k_kOsXR=u5O=fgyaNfaDM89cciSw@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Daniel Vetter <daniel@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <rob@ti.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, t.stanislaws@samsung.com, linux@arm.linux.org.uk, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Mon, Dec 05, 2011 at 04:11:46PM -0600, Rob Clark wrote:
> On Mon, Dec 5, 2011 at 3:23 PM, Daniel Vetter <daniel@ffwll.ch> wrote:
> > On Mon, Dec 05, 2011 at 02:46:47PM -0600, Rob Clark wrote:
> >> I sort of preferred having the DMABUF shim because that lets you pass
> >> a buffer around userspace without the receiving code knowing about a
> >> device specific API. =A0But the problem I eventually came around to: i=
f
> >> your GL stack (or some other userspace component) is batching up
> >> commands before submission to kernel, the buffers you need to wait for
> >> completion might not even be submitted yet. =A0So from kernel
> >> perspective they are "ready" for cpu access. =A0Even though in fact th=
ey
> >> are not in a consistent state from rendering perspective. =A0I don't
> >> really know a sane way to deal with that. =A0Maybe the approach instea=
d
> >> should be a userspace level API (in libkms/libdrm?) to provide
> >> abstraction for userspace access to buffers rather than dealing with
> >> this at the kernel level.
> >
> > Well, there's a reason GL has an explicit flush and extensions for sync
> > objects. It's to support such scenarios where the driver batches up gpu
> > commands before actually submitting them.
>
> Hmm.. what about other non-GL APIs..  maybe vaapi/vdpau or similar?
> (Or something that I haven't thought of.)

They generally all have a concept of when they've actually commited the
rendering to an X pixmap or egl image. Usually it's rather implicit, e.g.
the driver will submit any outstanding batches before returning from any
calls.
-Daniel
--=20
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
