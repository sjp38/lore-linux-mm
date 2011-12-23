Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id CC7C66B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 12:10:08 -0500 (EST)
Received: by vcge1 with SMTP id e1so8625670vcg.14
        for <linux-mm@kvack.org>; Fri, 23 Dec 2011 09:10:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAB2ybb_XcwLd8fx+vvditt+MUq2L2+WmsUpxH-gBKsbrVk7jGA@mail.gmail.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<CAF6AEGtOjO6Z6yfHz-ZGz3+NuEMH2M-8=20U6+-xt-gv9XtzaQ@mail.gmail.com>
	<20111220171437.GC3883@phenom.ffwll.local>
	<201112211727.17104.arnd@arndb.de>
	<CAB2ybb_XcwLd8fx+vvditt+MUq2L2+WmsUpxH-gBKsbrVk7jGA@mail.gmail.com>
Date: Fri, 23 Dec 2011 11:10:07 -0600
Message-ID: <CAF6AEGtGR0-vtfrP4i++kBxb2wGgGzv2MDu-K3CjmhEBXQyDnA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Semwal, Sumit" <sumit.semwal@ti.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Daniel Vetter <daniel@ffwll.ch>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Fri, Dec 23, 2011 at 4:00 AM, Semwal, Sumit <sumit.semwal@ti.com> wrote:
> On Wed, Dec 21, 2011 at 10:57 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Tuesday 20 December 2011, Daniel Vetter wrote:
>>> > I'm thinking for a first version, we can get enough mileage out of it by saying:
>>> > 1) only exporter can mmap to userspace
>>> > 2) only importers that do not need CPU access to buffer..
>
> Thanks Rob - and the exporter can do the mmap outside of dma-buf
> usage, right?

Yes

> I mean, we don't need to provide an mmap to dma_buf()
> and restrict it to exporter, when the exporter has more 'control' of
> the buffer anyways.

No, if it is only for the exporter, it really doesn't need to be in
dmabuf (ie. the exporter already knows how he is)

BR,
-R

>>
> BR,
> ~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
