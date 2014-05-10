Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id EC1A16B003B
	for <linux-mm@kvack.org>; Fri,  9 May 2014 23:25:19 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so1910041igb.3
        for <linux-mm@kvack.org>; Fri, 09 May 2014 20:25:19 -0700 (PDT)
Received: from nm40.bullet.mail.ne1.yahoo.com (nm40.bullet.mail.ne1.yahoo.com. [98.138.229.33])
        by mx.google.com with ESMTPS id aa7si4486058icc.48.2014.05.09.20.25.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 09 May 2014 20:25:19 -0700 (PDT)
References: <1399690747.69805.YahooMailNeo@web160104.mail.bf1.yahoo.com>
Message-ID: <1399692147.36921.YahooMailNeo@web160101.mail.bf1.yahoo.com>
Date: Fri, 9 May 2014 20:22:27 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [MM]: IOMMU and CMA buffer sharing
In-Reply-To: <1399690747.69805.YahooMailNeo@web160104.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

Hi, =0AI have some queries regarding IOMMU and CMA buffer sharing. =0AWe ha=
ve an embedded linux device (kernel 3.10, RAM: 256Mb) in which camera and c=
odec supports IOMMU but the display does not support IOMMU. =0AThus for cam=
era capture we are using iommu buffers using ION/DMABUF. But for all displa=
y rendering we are using CMA buffers. =0ASo, the question is how to achieve=
 buffer sharing (zero-copy) between Camera and Display using only IOMMU? =
=0ACurrently we are achieving zero-copy using CMA. And we are exploring opt=
ions to use IOMMU. =0ANow we wanted to know which option is better? To use =
IOMMU or CMA? =0AIf anybody have come across these design please share your=
 thoughts and results. =0AThank You! =0ARegards, =0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
