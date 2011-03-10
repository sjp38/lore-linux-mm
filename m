Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D24D68D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 21:48:56 -0500 (EST)
Received: by wwb28 with SMTP id 28so1253910wwb.26
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 18:48:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299673133-26464-1-git-send-email-johan.xx.mossberg@stericsson.com>
References: <1299673133-26464-1-git-send-email-johan.xx.mossberg@stericsson.com>
Date: Thu, 10 Mar 2011 11:48:51 +0900
Message-ID: <AANLkTi=Q6YRbRs1HHNEESxfCsu7_BeDXwfriDFLLrb85@mail.gmail.com>
Subject: Re: [PATCHv2 0/3] hwmem: Hardware memory driver
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: johan.xx.mossberg@stericsson.com
Cc: linux-mm@kvack.org, linaro-dev@lists.linaro.org, linux-media@vger.kernel.org, gstreamer-devel@lists.freedesktop.org, m.nazarewicz@samsung.com, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, =?UTF-8?B?6rCV66+86rec?= <mk7.kang@samsung.com>, =?UTF-8?B?64yA7J246riw?= <inki.dae@samsung.com>

Hi,

CCed updated Michal email address,

One note, As Michal moved to google, Marek is works on CMA. We are
also studying the hwmem and GEM.

Thank you,
Kyungmin Park

On Wed, Mar 9, 2011 at 9:18 PM,  <johan.xx.mossberg@stericsson.com> wrote:
> Hello everyone,
>
> The following patchset implements a "hardware memory driver". The
> main purpose of hwmem is:
>
> * To allocate buffers suitable for use with hardware. Currently
> this means contiguous buffers.
> * To synchronize the caches for the allocated buffers. This is
> achieved by keeping track of when the CPU uses a buffer and when
> other hardware uses the buffer, when we switch from CPU to other
> hardware or vice versa the caches are synchronized.
> * To handle sharing of allocated buffers between processes i.e.
> import, export.
>
> Hwmem is available both through a user space API and through a
> kernel API.
>
> Here at ST-Ericsson we use hwmem for graphics buffers. Graphics
> buffers need to be contiguous due to our hardware, are passed
> between processes (usually application and window manager)and are
> part of usecases where performance is top priority so we can't
> afford to synchronize the caches unecessarily.
>
> Additions in v2:
> * Bugfixes
> * Added the possibility to map hwmem buffers in the kernel through
> hwmem_kmap/kunmap
> * Moved mach specific stuff to mach.
>
> Best regards
> Johan Mossberg
> Consultant at ST-Ericsson
>
> Johan Mossberg (3):
> =A0hwmem: Add hwmem (part 1)
> =A0hwmem: Add hwmem (part 2)
> =A0hwmem: Add hwmem to ux500
>
> =A0arch/arm/mach-ux500/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0arch/arm/mach-ux500/board-mop500.c =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/arm/mach-ux500/dcache.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0266 ++++=
+++++
> =A0arch/arm/mach-ux500/devices.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 31 ++
> =A0arch/arm/mach-ux500/include/mach/dcache.h =A0| =A0 26 +
> =A0arch/arm/mach-ux500/include/mach/devices.h | =A0 =A01 +
> =A0drivers/misc/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/misc/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A01 +
> =A0drivers/misc/hwmem/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A07 =
+
> =A0drivers/misc/hwmem/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 =
+
> =A0drivers/misc/hwmem/cache_handler.c =A0 =A0 =A0 =A0 | =A0510 ++++++++++=
++++++++
> =A0drivers/misc/hwmem/cache_handler.h =A0 =A0 =A0 =A0 | =A0 61 +++
> =A0drivers/misc/hwmem/hwmem-ioctl.c =A0 =A0 =A0 =A0 =A0 | =A0455 ++++++++=
++++++++
> =A0drivers/misc/hwmem/hwmem-main.c =A0 =A0 =A0 =A0 =A0 =A0| =A0799 ++++++=
++++++++++++++++++++++
> =A0include/linux/hwmem.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
536 +++++++++++++++++++
> =A015 files changed, 2699 insertions(+), 1 deletions(-)
> =A0create mode 100644 arch/arm/mach-ux500/dcache.c
> =A0create mode 100644 arch/arm/mach-ux500/include/mach/dcache.h
> =A0create mode 100644 drivers/misc/hwmem/Kconfig
> =A0create mode 100644 drivers/misc/hwmem/Makefile
> =A0create mode 100644 drivers/misc/hwmem/cache_handler.c
> =A0create mode 100644 drivers/misc/hwmem/cache_handler.h
> =A0create mode 100644 drivers/misc/hwmem/hwmem-ioctl.c
> =A0create mode 100644 drivers/misc/hwmem/hwmem-main.c
> =A0create mode 100644 include/linux/hwmem.h
>
> --
> 1.7.4.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
