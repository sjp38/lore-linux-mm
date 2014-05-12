Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0120F6B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 05:42:42 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id gq1so7589982obb.36
        for <linux-mm@kvack.org>; Mon, 12 May 2014 02:42:42 -0700 (PDT)
Received: from bay0-omc3-s21.bay0.hotmail.com (bay0-omc3-s21.bay0.hotmail.com. [65.54.190.159])
        by mx.google.com with ESMTP id db3si6052640pbc.273.2014.05.12.02.42.42
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 02:42:42 -0700 (PDT)
Message-ID: <BAY169-W12541AD089785F8BFBD4E26EF350@phx.gbl>
From: Pintu Kumar <pintu.k@outlook.com>
Subject: Questions regarding DMA buffer sharing using IOMMU
Date: Mon, 12 May 2014 15:12:41 +0530
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

Hi=2C=A0=0A=
I have some queries regarding IOMMU and CMA buffer sharing.=A0=0A=
We have an embedded linux device (kernel 3.10=2C RAM: 256Mb) in which camer=
a and codec supports IOMMU but the display does not support IOMMU.=A0=0A=
Thus for camera capture we are using iommu buffers using ION/DMABUF. But fo=
r all display rendering we are using CMA buffers.=A0=0A=
So=2C the question is how to achieve buffer sharing (zero-copy) between Cam=
era and Display using only IOMMU?=A0=0A=
Currently we are achieving zero-copy using CMA. And we are exploring option=
s to use IOMMU.=A0=0A=
Now we wanted to know which option is better? To use IOMMU or CMA?=A0=0A=
If anybody have come across these design please share your thoughts and res=
ults.=A0=0A=
=0A=
=0A=
Thank You!=A0=0A=
Regards=2C=A0=0A=
Pintu=0A=
=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
