Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB9F6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 21:27:14 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so3881pdi.11
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 18:27:14 -0700 (PDT)
Received: from BAY004-OMC1S7.hotmail.com (bay004-omc1s7.hotmail.com. [65.54.190.18])
        by mx.google.com with ESMTPS id pl1si4087013pac.112.2014.07.11.18.27.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 11 Jul 2014 18:27:13 -0700 (PDT)
Message-ID: <BAY169-W80F409CBF18E8FE62CCD1DEF080@phx.gbl>
From: Pintu Kumar <pintu.k@outlook.com>
Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA areas
Date: Sat, 12 Jul 2014 06:57:12 +0530
In-Reply-To: <1404862900.76779.YahooMailNeo@web160102.mail.bf1.yahoo.com>
References: <1404862900.76779.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, "ngupta@vflare.org" <ngupta@vflare.org>, "minchan@kernel.org" <minchan@kernel.org>, "mgorman@suse.de" <mgorman@suse.de>
Cc: "pintu.k@samsung.com" <pintu.k@samsung.com>, "vishu_1385@yahoo.com" <vishu_1385@yahoo.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "mina86@mina86.com" <mina86@mina86.com>, "iqbalblr@gmail.com" <iqbalblr@gmail.com>

Hi All=2C=0A=
=0A=
No reply on the below.=0A=
=0A=
Does anybody came across with the similar issues?=0A=
Please let me know if any fixes are already available.=0A=
=0A=
Issues:=0A=
1) When free memory pages and CMA free pages are almost equal=2C min waterm=
ark check is failing=2C resulting in swapping.=0A=
2) Almost all the free memory in system is CMA free memory.=0A=
3) When ZRAM tries to allocate pages from CMA free areas=2C the allocation =
fails.=0A=
=0A=
Please refer below for more details.=0A=
=0A=
=0A=
=0A=
Thank you!=0A=
Regards=2C=0A=
Pintu=0A=
=0A=
=0A=
=0A=
> Date: Tue=2C 8 Jul 2014 16:41:40 -0700=0A=
> From: pintu_agarwal@yahoo.com=0A=
> Subject: [linux-3.10.17] Could not allocate memory from free CMA areas=0A=
> To: linux-mm@kvack.org=3B linux-mm@kvack.org=3B linux-arm-kernel@lists.in=
fradead.org=3B linaro-mm-sig@lists.linaro.org=0A=
> CC: pintu.k@outlook.com=3B pintu.k@samsung.com=3B vishu_1385@yahoo.com=3B=
 m.szyprowski@samsung.com=3B mina86@mina86.com=3B ngupta@vflare.org=3B iqba=
lblr@gmail.com=0A=
> =0A=
> Hi=2C=0A=
> =0A=
> We are facing one problem on linux 3.10 when we try to use CMA as large a=
s 56MB for 256MB RAM device.=0A=
> We found that after certain point of time (during boot)=2C min watermark =
check is failing when "free_pages" and "free_cma_pages" are almost equal an=
d falls below the min level.=0A=
> =0A=
> system details:=0A=
> ARM embedded device: RAM: 256MB=0A=
> Kernel version: 3.10.17=0A=
> Fixed Reserved memory: ~40MB=0A=
> Available memory: 217MB=0A=
> CMA reserved 1 : 56MB=0A=
> ZRAM configured: 128MB or 64MB=0A=
> min_free_kbytes: 1625 (default)=0A=
> Memory controller group enabled (MEMCG)=0A=
> =0A=
> =0A=
> After boot-up the "free -tm" command shows free memory as: ~50MB=0A=
> CMA is used for all UI display purposes. CMA used during bootup is close =
to ~6MB.=0A=
> Thus most of the free memory is in the form of CMA free memory.=0A=
> ZRAM getting uses was around ~5MB.=0A=
> =0A=
> =0A=
> During boot-up itself we observe that the following conditions are met.=
=0A=
> =0A=
> =0A=
> if (free_pages - free_cma <=3D min + lowmem_reserve) {=0A=
> =A0=A0=A0 printk"[PINTU]: __zone_watermark_ok: failed !\n")=3B=0A=
> =0A=
> =A0=A0=A0 return false=3B=0A=
> }=0A=
> Here: free_pages was: 12940=2C free_cma was: 12380=2C min: 566=2C lowmem:=
 0=0A=
> =0A=
> =0A=
> Thus is condition is met most of the time.=0A=
> And because of this watermark failure=2C Kswapd is waking up frequently.=
=0A=
> The /proc/pagetypeinfo reports that most of the higher order pages are fr=
om CMA regions.=0A=
> =0A=
> =0A=
> We also observed that ZRAM is trying to allocate memory from CMA region a=
nd failing.=0A=
> =0A=
> We also tried by decreasing the CMA region to 20MB. With this the waterma=
rk failure is not happening in boot time. But if we launch more than 3 apps=
 {Browser=2C music-player etc}=2C again the watermark started failing.=0A=
> =0A=
> Also we tried decreasing the min_free_kbytes=3D256=2C and with this also =
watermark is passed.=0A=
> =0A=
> Our observation is that ZRAM/zsmalloc trying to allocate memory from CMA =
areas and failed.=0A=
> =0A=
> =0A=
> Please let us know if anybody have come across the same problem and how t=
o resolve this issue.=0A=
> =0A=
> =0A=
> =0A=
> =0A=
> =0A=
> Thank You!=0A=
> Regards=2C=0A=
> Pintu=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
