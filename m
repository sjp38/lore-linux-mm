Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1B86B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 00:57:34 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id x130so27025849ite.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 21:57:34 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id 11si6299877itf.7.2016.08.04.21.57.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Aug 2016 21:57:33 -0700 (PDT)
Received: from epcas2p1.samsung.com (unknown [182.195.41.53])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OBF02KL373AXI80@mailout1.samsung.com> for linux-mm@kvack.org;
 Fri, 05 Aug 2016 13:57:10 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
Subject: [linux-mm] Drastic increase in application memory usage with Kernel
 version upgrade
Date: Fri, 05 Aug 2016 10:26:37 +0530
Message-id: <01a001d1eed5$c50726c0$4f157440$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
References: 
 <CGME20160805045709epcas3p1dc6f12f2fa3031112c4da5379e33b5e9@epcas3p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: jaejoon.seo@samsung.com, jy0.jeon@samsung.com, vishnu.ps@samsung.com, pintu.k@samsung.com

Hi All,

For one of our ARM embedded product, we recently updated the Kernel version from
3.4 to 3.18 and we noticed that the same application memory usage (PSS value)
gone up by ~10% and for some cases it even crossed ~50%.
There is no change in platform part. All platform component was built with ARM
32-bit toolchain.
However, the Kernel is changed from 32-bit to 64-bit.

Is upgrading Kernel version and moving from 32-bit to 64-bit is such a risk ?
After the upgrade, what can we do further to reduce the application memory usage
?
Is there any other factor that will help us to improve without major
modifications in platform ?

As a proof, we did a small experiment on our Ubuntu-32 bit machine.
We upgraded Ubuntu Kernel version from 3.13 to 4.01 and we observed the
following:
--------------------------------------------------------------------------------
-------------
|UBUNTU-32 bit		|Kernel 3.13	|Kernel 4.03	|DIFF	|
|CALCULATOR PSS	|6057 KB	|6466 KB	|409 KB	|
--------------------------------------------------------------------------------
-------------
So, just by upgrading the Kernel version: PSS value for calculator is increased
by 409KB.

If anybody knows any in-sight about it please point out more details about the
root cause.

Thank You!

Regards,
Pintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
