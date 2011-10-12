Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 13C5E6B002D
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 10:01:49 -0400 (EDT)
Received: by ywe9 with SMTP id 9so60333ywe.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 07:01:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAF6AEGuwMt6Snq=YSN4iddTv_Cu56aR_2BY1d3hjVvTdkom5MQ@mail.gmail.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
	<CAPM=9tzHOa5Dbe=SQz+AURMMbio4L7qoS8kUT3Ek0+HdtkrH4g@mail.gmail.com>
	<CAF6AEGs6kkGp85NoNVuq5W9i=WE86V8wvAtKydX=D3bQOc+6Pw@mail.gmail.com>
	<CAPM=9twft0eBEUoCD11a2gTZHwOaPzFmZvBfE032dfK10eQ27Q@mail.gmail.com>
	<CAF6AEGuwMt6Snq=YSN4iddTv_Cu56aR_2BY1d3hjVvTdkom5MQ@mail.gmail.com>
Date: Wed, 12 Oct 2011 15:01:37 +0100
Message-ID: <CAPM=9tyKjodxf9MKjG=5bBDZTuqOx4Nu31L5iNN9LrO9fsp+FA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Sumit Semwal <sumit.semwal@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch

> But then we'd need a different set of accessors for every different
> drm/v4l/etc driver, wouldn't we?

Not any more different than you need for this, you just have a new
interface that you request a sw object from,
then mmap that object, and underneath it knows who owns it in the kernel.

mmap just feels wrong in this API, which is a buffer sharing API not a
buffer mapping API.

> I guess if sharing a buffer between multiple drm devices, there is
> nothing stopping you from having some NOT_DMABUF_MMAPABLE flag you
> pass when the buffer is allocated, then you don't have to support
> dmabuf->mmap(), and instead mmap via device and use some sort of
> DRM_CPU_PREP/FINI ioctls for synchronization..

Or we could make a generic CPU accessor that we don't have to worry about.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
