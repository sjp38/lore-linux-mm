Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A82596B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 17:35:04 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2278552vbb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 14:35:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1781399.9f45Chd7K4@wuerfel>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<201112051718.48324.arnd@arndb.de>
	<CAF6AEGvyWV0DM2fjBbh-TNHiMmiLF4EQDJ6Uu0=NkopM6SXS6g@mail.gmail.com>
	<1781399.9f45Chd7K4@wuerfel>
Date: Mon, 5 Dec 2011 16:35:03 -0600
Message-ID: <CAF6AEGugC4hW-NUU4Zss=ACSCrqads+=nwULGRaMhhTX-1uP+g@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Rob Clark <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, t.stanislaws@samsung.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-media@vger.kernel.org, Sumit Semwal <sumit.semwal@linaro.org>, m.szyprowski@samsung.com

On Mon, Dec 5, 2011 at 4:09 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 05 December 2011 14:46:47 Rob Clark wrote:
>> I sort of preferred having the DMABUF shim because that lets you pass
>> a buffer around userspace without the receiving code knowing about a
>> device specific API. =A0But the problem I eventually came around to: if
>> your GL stack (or some other userspace component) is batching up
>> commands before submission to kernel, the buffers you need to wait for
>> completion might not even be submitted yet. =A0So from kernel
>> perspective they are "ready" for cpu access. =A0Even though in fact they
>> are not in a consistent state from rendering perspective. =A0I don't
>> really know a sane way to deal with that. =A0Maybe the approach instead
>> should be a userspace level API (in libkms/libdrm?) to provide
>> abstraction for userspace access to buffers rather than dealing with
>> this at the kernel level.
>
> It would be nice if user space had no way to block out kernel drivers,
> otherwise we have to be very careful to ensure that each map() operation
> can be interrupted by a signal as the last resort to avoid deadlocks.

map_dma_buf should be documented to be allowed to return -EINTR..
otherwise, yeah, that would be problematic.

> =A0 =A0 =A0 =A0Arnd
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/dri-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
