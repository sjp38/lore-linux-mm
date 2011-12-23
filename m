Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E51EA6B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 12:20:07 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so10154909vbb.14
        for <linux-mm@kvack.org>; Fri, 23 Dec 2011 09:20:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAB2ybb-+VTR=V1hwhF1GKxgkhTrssZ1JVOwcP6spO5O3AXqivA@mail.gmail.com>
References: <1324283611-18344-1-git-send-email-sumit.semwal@ti.com>
	<20111220193117.GD3883@phenom.ffwll.local>
	<CAPM=9tzi5MyCBMJhWBM_ouL=QOaxX3K6KZ8K+t7dUYJLQrF+yA@mail.gmail.com>
	<CAB2ybb-+VTR=V1hwhF1GKxgkhTrssZ1JVOwcP6spO5O3AXqivA@mail.gmail.com>
Date: Fri, 23 Dec 2011 11:20:06 -0600
Message-ID: <CAF6AEGs-Xgi_kmz5oag76=4v20RP5PfAM2-pyt_PyvWizgdW8Q@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v3 0/2] Introduce DMA buffer sharing mechanism
From: Rob Clark <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Semwal, Sumit" <sumit.semwal@ti.com>
Cc: Dave Airlie <airlied@gmail.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, t.stanislaws@samsung.com, patches@linaro.org, daniel@ffwll.ch

On Fri, Dec 23, 2011 at 4:08 AM, Semwal, Sumit <sumit.semwal@ti.com> wrote:
> On Wed, Dec 21, 2011 at 1:50 AM, Dave Airlie <airlied@gmail.com> wrote:
> <snip>
>>>
>>> I think this is a really good v1 version of dma_buf. It contains all th=
e
>>> required bits (with well-specified semantics in the doc patch) to
>>> implement some basic use-cases and start fleshing out the integration w=
ith
>>> various subsystem (like drm and v4l). All the things still under
>>> discussion like
>>> - userspace mmap support
>>> - more advanced (and more strictly specified) coherency models
>>> - and shared infrastructure for implementing exporters
>>> are imo much clearer once we have a few example drivers at hand and a
>>> better understanding of some of the insane corner cases we need to be a=
ble
>>> to handle.
>>>
>>> And I think any risk that the resulting clarifications will break a bas=
ic
>>> use-case is really minimal, so I think it'd be great if this could go i=
nto
>>> 3.3 (maybe as some kind of staging/experimental infrastructure).
>>>
>>> Hence for both patches:
>>> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
>>
>> Yeah I'm with Daniel, I like this one, I can definitely build the drm
>> buffer sharing layer on top of this.
>>
>> How do we see this getting merged? I'm quite happy to push it to Linus
>> if we don't have an identified path, though it could go via a Linaro
>> tree as well.
>>
>> so feel free to add:
>> Reviewed-by: Dave Airlie <airlied@redhat.com>
> Thanks Daniel and Dave!
>
> I guess we can start with staging for 3.3, and see how it shapes up. I
> will post the latest patch version pretty soon.

not sure about staging, but could make sense to mark as experimental.

> Arnd, Dave: do you have any preference on the path it takes to get
> merged? In my mind, Linaro tree might make more sense, but I would
> leave it upto you gentlemen.

Looks like Dave is making some progress on drm usage of buffer sharing
between gpu's.. if that is ready to go in at the same time, it might
be a bit logistically simpler for him to put dmabuf in the same pull
req.  I don't have strong preference one way or another, so do what is
collectively simpler ;-)

BR,
-R

>>
>> Dave.
> Best regards,
> ~Sumit.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
