Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DD8196B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 05:59:35 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so5973355pdj.2
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:59:35 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id zz2si21904147pbc.124.2014.09.15.02.59.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 02:59:34 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 17:59:27 +0800
Subject: RE: [RFC] arm:extend the reserved mrmory for initrd to be page
	aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491605@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net>
 <20140915084616.GX12361@n2100.arm.linux.org.uk>
 <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net>
 <20140915093014.GZ12361@n2100.arm.linux.org.uk>
In-Reply-To: <20140915093014.GZ12361@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

Hi

Add more log:
<4>[    0.000000] INITRD unalign phys address:0x02000000+0x0022fb0e
<4>[    0.000000] INITRD aligned phys address:0x02000000+0x00230000
<4>[    0.574868] free_initrd: free initrd 0xc2000000+0xc222fb0e
<4>[    0.579398] free_initrd_mem: free pfn:8192---8752

The inird used memory is still the same as the one passed by bootloads,
I don't change it. It should be safe.


-----Original Message-----
From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]=20
Sent: Monday, September 15, 2014 5:30 PM
To: Wang, Yalin
Cc: 'Will Deacon'; 'linux-kernel@vger.kernel.org'; 'linux-arm-kernel@lists.=
infradead.org'; 'linux-mm@kvack.org'; linux-arm-msm@vger.kernel.org
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page ali=
gned

On Mon, Sep 15, 2014 at 05:07:53PM +0800, Wang, Yalin wrote:
> Hi
>=20
> I tested it on my phone,
> >From log:
> <4>[    0.000000] INITRD unalign phys address:0x02000000+0x0022fb0e
> <4>[    0.000000] INITRD aligned phys address:0x02000000+0x00230000
>=20
> <4>[    0.579474] free_initrd_mem: free pfn:8192---8752
>=20
> The tail address is not aligned for most initrd image, This page will=20
> not be freed and lost .

Right, so from this I can assume that you only tested it by seeing what the=
 addresses were, and the values used in free_initrd_mem().

What you haven't tested is whether the initrd actually gets used with your =
changes, which is more what I was interested in given what I found when rea=
ding your patch.

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up accor=
ding to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
