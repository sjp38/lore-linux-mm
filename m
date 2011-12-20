Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 40D9C6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 15:20:29 -0500 (EST)
Received: by yhgm50 with SMTP id m50so3843204yhg.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 12:20:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111220193117.GD3883@phenom.ffwll.local>
References: <1324283611-18344-1-git-send-email-sumit.semwal@ti.com>
	<20111220193117.GD3883@phenom.ffwll.local>
Date: Tue, 20 Dec 2011 20:20:28 +0000
Message-ID: <CAPM=9tzi5MyCBMJhWBM_ouL=QOaxX3K6KZ8K+t7dUYJLQrF+yA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v3 0/2] Introduce DMA buffer sharing mechanism
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, t.stanislaws@samsung.com, patches@linaro.org
Cc: daniel@ffwll.ch

>>
>> This is RFC v3 for DMA buffer sharing mechanism - changes from v2 are in=
 the
>> changelog below.
>>
>> Various subsystems - V4L2, GPU-accessors, DRI to name a few - have felt =
the
>> need to have a common mechanism to share memory buffers across different
>> devices - ARM, video hardware, GPU.
>>
>> This need comes forth from a variety of use cases including cameras, ima=
ge
>> processing, video recorders, sound processing, DMA engines, GPU and disp=
lay
>> buffers, and others.
>>
>> This RFC is an attempt to define such a buffer sharing mechanism- it is =
the
>> result of discussions from a couple of memory-management mini-summits he=
ld by
>> Linaro to understand and address common needs around memory management. =
[1]
>>
>> A new dma_buf buffer object is added, with operations and API to allow e=
asy
>> sharing of this buffer object across devices.
>>
>> The framework allows:
>> - a new buffer-object to be created with fixed size.
>> - different devices to 'attach' themselves to this buffer, to facilitate
>> =A0 backing storage negotiation, using dma_buf_attach() API.
>> - association of a file pointer with each user-buffer and associated
>> =A0 =A0allocator-defined operations on that buffer. This operation is ca=
lled the
>> =A0 =A0'export' operation.
>> - this exported buffer-object to be shared with the other entity by aski=
ng for
>> =A0 =A0its 'file-descriptor (fd)', and sharing the fd across.
>> - a received fd to get the buffer object back, where it can be accessed =
using
>> =A0 =A0the associated exporter-defined operations.
>> - the exporter and user to share the scatterlist using map_dma_buf and
>> =A0 =A0unmap_dma_buf operations.
>>
>> Documentation present in the patch-set gives more details.
>>
>> This is based on design suggestions from many people at the mini-summits=
,
>> most notably from Arnd Bergmann <arnd@arndb.de>, Rob Clark <rob@ti.com> =
and
>> Daniel Vetter <daniel@ffwll.ch>.
>>
>> The implementation is inspired from proof-of-concept patch-set from
>> Tomasz Stanislawski <t.stanislaws@samsung.com>, who demonstrated buffer =
sharing
>> between two v4l2 devices. [2]
>>
>> References:
>> [1]: https://wiki.linaro.org/OfficeofCTO/MemoryManagement
>> [2]: http://lwn.net/Articles/454389
>>
>> Patchset based on top of 3.2-rc3, the current version can be found at
>>
>> http://git.linaro.org/gitweb?p=3Dpeople/sumitsemwal/linux-3.x.git
>> Branch: dma-buf-upstr-v2
>>
>> Earlier versions:
>> v2 at: https://lkml.org/lkml/2011/12/2/53
>> v1 at: https://lkml.org/lkml/2011/10/11/92
>>
>> Best regards,
>> ~Sumit Semwal
>
> I think this is a really good v1 version of dma_buf. It contains all the
> required bits (with well-specified semantics in the doc patch) to
> implement some basic use-cases and start fleshing out the integration wit=
h
> various subsystem (like drm and v4l). All the things still under
> discussion like
> - userspace mmap support
> - more advanced (and more strictly specified) coherency models
> - and shared infrastructure for implementing exporters
> are imo much clearer once we have a few example drivers at hand and a
> better understanding of some of the insane corner cases we need to be abl=
e
> to handle.
>
> And I think any risk that the resulting clarifications will break a basic
> use-case is really minimal, so I think it'd be great if this could go int=
o
> 3.3 (maybe as some kind of staging/experimental infrastructure).
>
> Hence for both patches:
> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

Yeah I'm with Daniel, I like this one, I can definitely build the drm
buffer sharing layer on top of this.

How do we see this getting merged? I'm quite happy to push it to Linus
if we don't have an identified path, though it could go via a Linaro
tree as well.

so feel free to add:
Reviewed-by: Dave Airlie <airlied@redhat.com>

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
