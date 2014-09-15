Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D7C286B0037
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:22:19 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so6205718pab.27
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:22:19 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id hj2si22014327pac.169.2014.09.15.03.22.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 03:22:18 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 18:22:12 +0800
Subject: RE: [RFC] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491606@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net>
 <20140915084616.GX12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net>
 <20140915093014.GZ12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB491605@CNBJMBX05.corpusers.net>
 <20140915101632.GA12361@n2100.arm.linux.org.uk>
In-Reply-To: <20140915101632.GA12361@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

Hi

Oh, I see your meaning,
Yeah , my initrd is a cpio image,
And it can still work after apply this patch.


-----Original Message-----
From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]=20
Sent: Monday, September 15, 2014 6:17 PM
To: Wang, Yalin
Cc: 'Will Deacon'; 'linux-kernel@vger.kernel.org'; 'linux-arm-kernel@lists.=
infradead.org'; 'linux-mm@kvack.org'; linux-arm-msm@vger.kernel.org
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page ali=
gned

On Mon, Sep 15, 2014 at 05:59:27PM +0800, Wang, Yalin wrote:
> Hi
>=20
> Add more log:
> <4>[    0.000000] INITRD unalign phys address:0x02000000+0x0022fb0e
> <4>[    0.000000] INITRD aligned phys address:0x02000000+0x00230000
> <4>[    0.574868] free_initrd: free initrd 0xc2000000+0xc222fb0e
> <4>[    0.579398] free_initrd_mem: free pfn:8192---8752
>=20
> The inird used memory is still the same as the one passed by=20
> bootloads, I don't change it. It should be safe.

This tells me nothing about whether the initrd is actually /used/.  What it=
 tells me is that it's being freed.  The function of an initrd is not to be=
 a chunk of memory which gets freed later on in the boot process.
It is there to provide an "initial ramdisk" (whether it be a filesystem ima=
ge, or a CPIO compressed archive) for userspace to run.

So, have you checked that initrd is still functional after this patch?

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up accor=
ding to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
