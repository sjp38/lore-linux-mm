Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id EAA7C6B005A
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 11:41:46 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so6807601vbb.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 08:41:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112201541.17904.arnd@arndb.de>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<201112121648.52126.arnd@arndb.de>
	<CAB2ybb_dU7BzJmPo6vA92pe1YCNerCLc+bv7Qi_EfkfGaik6bQ@mail.gmail.com>
	<201112201541.17904.arnd@arndb.de>
Date: Tue, 20 Dec 2011 10:41:45 -0600
Message-ID: <CAF6AEGtOjO6Z6yfHz-ZGz3+NuEMH2M-8=20U6+-xt-gv9XtzaQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Semwal, Sumit" <sumit.semwal@ti.com>, Daniel Vetter <daniel@ffwll.ch>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Tue, Dec 20, 2011 at 9:41 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 19 December 2011, Semwal, Sumit wrote:
>> I didn't see a consensus on whether dma_buf should enforce some form
>> of serialization within the API - so atleast for v1 of dma-buf, I
>> propose to 'not' impose a restriction, and we can tackle it (add new
>> ops or enforce as design?) whenever we see the first need of it - will
>> that be ok? [I am bending towards the thought that it is a problem to
>> solve at a bigger platform than dma_buf.]
>
> The problem is generally understood for streaming mappings with a
> single device using it: if you have a long-running mapping, you have
> to use dma_sync_*. This obviously falls apart if you have multiple
> devices and no serialization between the accesses.
>
> If you don't want serialization, that implies that we cannot have
> use the =A0dma_sync_* API on the buffer, which in turn implies that
> we cannot have streaming mappings. I think that's ok, but then
> you have to bring back the mmap API on the buffer if you want to
> allow any driver to provide an mmap function for a shared buffer.

I'm thinking for a first version, we can get enough mileage out of it by sa=
ying:
1) only exporter can mmap to userspace
2) only importers that do not need CPU access to buffer..

This way we can get dmabuf into the kernel, maybe even for 3.3.  I
know there are a lot of interesting potential uses where this stripped
down version is good enough.  It probably isn't the final version,
maybe more features are added over time to deal with importers that
need CPU access to buffer, sync object, etc.  But we have to start
somewhere.

BR,
-R

> =A0 =A0 =A0 =A0Arnd
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
