Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id ADBFE6B005A
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 09:29:43 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so3245926obc.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 06:29:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111220020549.GQ6559@morell.nvidia.com>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<4EE33EC2.6050508@redhat.com>
	<20111212224408.GD4355@morell.nvidia.com>
	<201112131510.02785.arnd@arndb.de>
	<20111220020549.GQ6559@morell.nvidia.com>
Date: Tue, 20 Dec 2011 16:29:42 +0200
Message-ID: <CAJL_dMvYYWyx8xD4B75wXdKg+bD959i1LTWXD8b+yrW6HuxnTg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
From: Anca Emanuel <anca.emanuel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Morell <rmorell@nvidia.com>
Cc: Arnd Bergmann <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Mauro Carvalho Chehab <mchehab@redhat.com>, Sumit Semwal <sumit.semwal@ti.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "jesse.barker@linaro.org" <jesse.barker@linaro.org>, "daniel@ffwll.ch" <daniel@ffwll.ch>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Dec 20, 2011 at 4:05 AM, Robert Morell <rmorell@nvidia.com> wrote:
>
> One of the goals of this project is to unify the fragmented space of the
> ARM SoC memory managers so that each vendor doesn't implement their own,
> and they can all be closer to mainline.

That is a very good objective.

> I fear that restricting the use of this buffer sharing mechanism to GPL
> drivers only will prevent that goal from being achieved, if an SoC
> driver has to interact with modules that use a non-GPL license.

If nobody from nvidia have any experience with this kind of work...
Look at Intel. Why are you afraid of ?

> As a hypothetical example, consider laptops that have multiple GPUs.
> Today, these ship with onboard graphics (integrated to the CPU or
> chipset) along with a discrete GPU, where in many cases only the onboard
> graphics can actually display to the screen. =A0In order for anything
> rendered by the discrete GPU to be displayed, it has to be copied to
> memory available for the smaller onboard graphics to texture from or
> display directly. =A0Obviously, that's best done by sharing dma buffers
> rather than bouncing them through the GPU. =A0It's not much of a stretch
> to imagine that we'll see such systems with a Tegra CPU/GPU plus a
> discrete GPU in the future; in that case, we'd want to be able to share
> memory between the discrete GPU and the Tegra system. =A0In that scenario=
,
> if this interface is GPL-only, we'd be unable to adopt the dma_buffer
> sharing mechanism for Tegra.
>
> (This isn't too pie-in-the-sky, either; people are already combining
> Tegra with discrete GPUs:
> http://blogs.nvidia.com/2011/11/world%e2%80%99s-first-arm-based-supercomp=
uter-to-launch-in-barcelona/
> )
>
> Thanks,
> Robert

There are other problems ? Some secret agreements with Microsoft ?

I hope to see something open sourced. You can do it nVidia.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
