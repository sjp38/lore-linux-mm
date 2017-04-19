Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 493772806D8
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:41:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o21so2320211wrb.9
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 05:41:59 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id y2si3933183wmh.19.2017.04.19.05.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 05:41:58 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [Linaro-mm-sig] [PATCHv4 12/12] staging/android: Update Ion TODO list
Date: Wed, 19 Apr 2017 15:42:55 +0300
Message-ID: <2224092.7NJfpfE285@avalon>
In-Reply-To: <20170419083655.egqgf34dxdwpyomx@phenom.ffwll.local>
References: <1492540034-5466-1-git-send-email-labbott@redhat.com> <1492540034-5466-13-git-send-email-labbott@redhat.com> <20170419083655.egqgf34dxdwpyomx@phenom.ffwll.local>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, romlem@google.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, Brian Starkey <brian.starkey@arm.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hi Daniel,

On Wednesday 19 Apr 2017 10:36:55 Daniel Vetter wrote:
> On Tue, Apr 18, 2017 at 11:27:14AM -0700, Laura Abbott wrote:
> > Most of the items have been taken care of by a clean up series. Rem=
ove
> > the completed items and add a few new ones.
> >=20
> > Signed-off-by: Laura Abbott <labbott@redhat.com>
> > ---
> >=20
> >  drivers/staging/android/TODO | 21 ++++-----------------
> >  1 file changed, 4 insertions(+), 17 deletions(-)
> >=20
> > diff --git a/drivers/staging/android/TODO b/drivers/staging/android=
/TODO
> > index 8f3ac37..5f14247 100644
> > --- a/drivers/staging/android/TODO
> > +++ b/drivers/staging/android/TODO
> >=20
> > @@ -7,23 +7,10 @@ TODO:
> >  ion/
> >=20
> > - - Remove ION_IOC_SYNC: Flushing for devices should be purely a ke=
rnel
> > internal -   interface on top of dma-buf. flush_for_device needs to=
 be
> > added to dma-buf -   first.
> > - - Remove ION_IOC_CUSTOM: Atm used for cache flushing for cpu acce=
ss in
> > some -   vendor trees. Should be replaced with an ioctl on the dma-=
buf to
> > expose the -   begin/end_cpu_access hooks to userspace.
> > - - Clarify the tricks ion plays with explicitly managing coherency=
 behind
> > the -   dma api's back (this is absolutely needed for high-perf gpu=

> > drivers): Add an -   explicit coherency management mode to
> > flush_for_device to be used by drivers -   which want to manage cac=
hes
> > themselves and which indicates whether cpu caches -   need flushing=
.
> > - - With those removed there's probably no use for ION_IOC_IMPORT a=
nymore
> > either -   since ion would just be the central allocator for shared=

> > buffers. - - Add dt-binding to expose cma regions as ion heaps, wit=
h the
> > rule that any -   such cma regions must already be used by some dev=
ice
> > for dma. I.e. ion only -   exposes existing cma regions and doesn't=

> > reserve unecessarily memory when -   booting a system which doesn't=
 use
> > ion.
> > + - Add dt-bindings for remaining heaps (chunk and carveout heaps).=
 This
> > would +   involve putting appropriate bindings in a memory node for=
 Ion
> > to find. + - Split /dev/ion up into multiple nodes (e.g. /dev/ion/h=
eap0)
> > + - Better test framework (integration with VGEM was suggested)
>=20
> Found another one: Integrate the ion kernel-doc into
> Documenation/gpu/ion.rst and link it up within Documenation/gpu/index=
.rst.

If ion is a generic-purpose allocator, should its documentation really =
reside=20
in Documentation/gpu/ ?

> There's a lot of api and overview stuff already around, would be grea=
t to
> make this more accessible.
>=20
> But I wouldn't put this as a de-staging blocker, just an idea.
>=20
> On the series: Acked-by: Daniel Vetter <daniel.vetter@ffwll.ch>
>=20
> No full review since a bunch of stuff I'm not too familiar with, but =
I
> like where this is going.
> -Daniel
>=20
> >  Please send patches to Greg Kroah-Hartman <greg@kroah.com> and Cc:=

> >  Arve Hj=F8nnev=E5g <arve@android.com> and Riley Andrews
> >  <riandrews@android.com>

--=20
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
