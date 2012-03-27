Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 5B84C6B0106
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 17:53:09 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 05/14] IA64: adapt for dma_map_ops changes
Date: Tue, 27 Mar 2012 21:53:01 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F15B724D8@ORSMSX104.amr.corp.intel.com>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
	<1324643253-3024-6-git-send-email-m.szyprowski@samsung.com>
 <CA+8MBbLAafFbVwviFmkjD0DNz5RsCbB_TNLL67wEi2k-hyXkXA@mail.gmail.com>
In-Reply-To: <CA+8MBbLAafFbVwviFmkjD0DNz5RsCbB_TNLL67wEi2k-hyXkXA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, "microblaze-uclinux@itee.uq.edu.au" <microblaze-uclinux@itee.uq.edu.au>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "discuss@x86-64.org" <discuss@x86-64.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

> until part 5 (when ia64 sees the changes to match).  You could either mer=
ge part
> 5 into part 2 (to make a combined x86+ia64 piece

Doh! I see that you already did this in the re-post you did a few hours
ago (which my mail client had filed away in my linux-arch folder).

-Tony
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
