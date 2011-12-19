Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B583A6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 01:17:01 -0500 (EST)
Received: by mail-vx0-f174.google.com with SMTP id fk14so5402828vcb.33
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 22:17:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112121648.52126.arnd@arndb.de>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
 <20111209142405.6f371be6@pyramind.ukuu.org.uk> <CAKMK7uH+4uSYYjBLcvfhVC+iwGUZ09Z4p64fNBzh196aG+hqgg@mail.gmail.com>
 <201112121648.52126.arnd@arndb.de>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Mon, 19 Dec 2011 11:46:40 +0530
Message-ID: <CAB2ybb_dU7BzJmPo6vA92pe1YCNerCLc+bv7Qi_EfkfGaik6bQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC v2 1/2] dma-buf: Introduce dma buffer
 sharing mechanism
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Vetter <daniel@ffwll.ch>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi Arnd, Daniel,

On Mon, Dec 12, 2011 at 10:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Saturday 10 December 2011, Daniel Vetter wrote:
>> If userspace (through some driver calls)
>> tries to do stupid things, it'll just get garbage. See
>> Message-ID: <CAKMK7uHeXYn-v_8cmpLNWsFY14KtmuRZy8YRKR5Xst2-2WdFSQ@mail.gm=
ail.com>
>> for my reasons why it think this is the right way to go forward. So in
>> essence I'm really interested in the reasons why you want the kernel
>> to enforce this (or I'm completely missing what's the contentious
>> issue here).
>
> This has nothing to do with user space mappings. Whatever user space does=
,
> you get garbage if you don't invalidate cache lines that were introduced
> through speculative prefetching before you access cache lines that were
> DMA'd from a device.
I didn't see a consensus on whether dma_buf should enforce some form
of serialization within the API - so atleast for v1 of dma-buf, I
propose to 'not' impose a restriction, and we can tackle it (add new
ops or enforce as design?) whenever we see the first need of it - will
that be ok? [I am bending towards the thought that it is a problem to
solve at a bigger platform than dma_buf.]
>
> =A0 =A0 =A0 =A0Arnd

Best regards,
~Sumit.
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
