Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 722726B0039
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 05:16:27 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id w10so5861846pde.13
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:16:27 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id ba9si21696963pdb.146.2014.09.15.02.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 02:16:26 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 17:07:53 +0800
Subject: RE: [RFC] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491604@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB4915FC@CNBJMBX05.corpusers.net>
 <20140915084616.GX12361@n2100.arm.linux.org.uk>
In-Reply-To: <20140915084616.GX12361@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

Hi

I tested it on my phone,
>From log:
<4>[    0.000000] INITRD unalign phys address:0x02000000+0x0022fb0e
<4>[    0.000000] INITRD aligned phys address:0x02000000+0x00230000

<4>[    0.579474] free_initrd_mem: free pfn:8192---8752

The tail address is not aligned for most initrd image,
This page will not be freed and lost .

This patch have a limitation that the tail page's not used
Part should not be reserved by any other driver,
And must be memory .
This is true for most bootloaders ,
And we will print error if it is false .

Thanks


-----Original Message-----
From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]=20
Sent: Monday, September 15, 2014 4:46 PM
To: Wang, Yalin
Cc: 'Will Deacon'; 'linux-kernel@vger.kernel.org'; 'linux-arm-kernel@lists.=
infradead.org'; 'linux-mm@kvack.org'; linux-arm-msm@vger.kernel.org
Subject: Re: [RFC] arm:extend the reserved mrmory for initrd to be page ali=
gned

On Mon, Sep 15, 2014 at 01:11:14PM +0800, Wang, Yalin wrote:
> this patch extend the start and end address of initrd to be page=20
> aligned, so that we can free all memory including the un-page aligned=20
> head or tail page of initrd, if the start or end address of initrd are=20
> not page aligned, the page can't be freed by free_initrd_mem() function.

Have you tested this patch?  If so, how thorough was your testing?

--
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up accor=
ding to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
