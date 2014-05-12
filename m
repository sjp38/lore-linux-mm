Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4370C6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 10:37:12 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so8641136pab.14
        for <linux-mm@kvack.org>; Mon, 12 May 2014 07:37:11 -0700 (PDT)
Received: from bay0-omc1-s14.bay0.hotmail.com (bay0-omc1-s14.bay0.hotmail.com. [65.54.190.25])
        by mx.google.com with ESMTP id ud10si6439180pbc.460.2014.05.12.07.37.11
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 07:37:11 -0700 (PDT)
Message-ID: <BAY169-W1156E6803829CAB545274BCEF350@phx.gbl>
From: Pintu Kumar <pintu.k@outlook.com>
Subject: RE: Questions regarding DMA buffer sharing using IOMMU
Date: Mon, 12 May 2014 20:07:10 +0530
In-Reply-To: <5218408.5YRJXjS4BX@wuerfel>
References: 
 <BAY169-W12541AD089785F8BFBD4E26EF350@phx.gbl>,<5218408.5YRJXjS4BX@wuerfel>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

Hi=2C=0A=
Thanks for the reply.=0A=
=0A=
----------------------------------------=0A=
> From: arnd@arndb.de=0A=
> To: linux-arm-kernel@lists.infradead.org=0A=
> CC: pintu.k@outlook.com=3B linux-mm@kvack.org=3B linux-kernel@vger.kernel=
.org=3B linaro-mm-sig@lists.linaro.org=0A=
> Subject: Re: Questions regarding DMA buffer sharing using IOMMU=0A=
> Date: Mon=2C 12 May 2014 14:00:57 +0200=0A=
>=0A=
> On Monday 12 May 2014 15:12:41 Pintu Kumar wrote:=0A=
>> Hi=2C=0A=
>> I have some queries regarding IOMMU and CMA buffer sharing.=0A=
>> We have an embedded linux device (kernel 3.10=2C RAM: 256Mb) in=0A=
>> which camera and codec supports IOMMU but the display does not support I=
OMMU.=0A=
>> Thus for camera capture we are using iommu buffers using=0A=
>> ION/DMABUF. But for all display rendering we are using CMA buffers.=0A=
>> So=2C the question is how to achieve buffer sharing (zero-copy)=0A=
>> between Camera and Display using only IOMMU?=0A=
>> Currently we are achieving zero-copy using CMA. And we are=0A=
>> exploring options to use IOMMU.=0A=
>> Now we wanted to know which option is better? To use IOMMU or CMA?=0A=
>> If anybody have come across these design please share your thoughts and =
results.=0A=
>=0A=
> There is a slight performance overhead in using the IOMMU in general=2C=
=0A=
> because the IOMMU has to fetch the page table entries from memory=0A=
> at least some of the time.=0A=
=0A=
Ok=2C we need to check performance later=0A=
=0A=
>=0A=
> If that overhead is within the constraints you have for transfers between=
=0A=
> camera and codec=2C you are always better off using IOMMU since that=0A=
> means you don't have to do memory migration.=0A=
=0A=
Transfer between camera is codec is fine. But our major concern is single b=
uffer=A0=0A=
sharing between camera & display. Here camera supports iommu but display do=
es not support iommu.=0A=
Is it possible to render camera preview (iommu buffers) on display (not iom=
mu and required physical contiguous overlay memory)?=0A=
=0A=
Also is it possible to buffer sharing between 2 iommu supported devices?=0A=
=0A=
>=0A=
> Note however=2C that we don't have a way to describe IOMMU relations=0A=
> to devices in DT=2C so whatever you come up with to do this will most=0A=
> likely be incompatible with what we do in future kernel versions.=0A=
>=0A=
> Arnd=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
