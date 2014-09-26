Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8651B6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 04:52:29 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id r10so12587204pdi.39
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 01:52:29 -0700 (PDT)
Received: from BAY004-OMC2S26.hotmail.com (bay004-omc2s26.hotmail.com. [65.54.190.101])
        by mx.google.com with ESMTPS id kn10si1977067pbd.49.2014.09.26.01.52.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Sep 2014 01:52:28 -0700 (PDT)
Message-ID: <BAY169-W38291C97E5E42E5DCA8787EFBF0@phx.gbl>
From: Pintu Kumar <pintu.k@outlook.com>
Subject: Changing PAGE_ALLOC_COSTLY_ORDER from 3 to 2
Date: Fri, 26 Sep 2014 14:22:27 +0530
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mgorman@suse.de" <mgorman@suse.de>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, PINTU KUMAR <pintu_agarwal@yahoo.com>, "pintu.k@samsung.com" <pintu.k@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi=2C=0A=
=0A=
I wanted to know about the impact of changing PAGE_ALLOC_COSTLY_ORDER value=
 from 3 to 2.=0A=
This macro is defined in include/linux/mmzone.h=0A=
#define PAGE_ALLOC_COSTLY_ORDER=A0=A0 3=0A=
=0A=
As I know this value should never be changed irrespective of the type of th=
e system.=0A=
Is it good to change this value for RAM size: 512MB=2C 256MB or 128MB?=0A=
If anybody have changed this value and experience any kind of problem or be=
nefits please let us know.=0A=
=0A=
We noticed that for one of the Android product with 512MB RAM=2C the PAGE_A=
LLOC_COSTLY_ORDER was set to 2.=0A=
We could not figure out why this value was decreased from 3 to 2.=0A=
=0A=
As per my analysis=2C I observed that kmalloc fails little early=2C if we c=
hange this value to 2.=0A=
This is also visible from the _slowpath_ in page_alloc.c=0A=
=0A=
Apart from this we could not find any other impact.=0A=
If anybody is aware of any other impact=2C please let us know.=0A=
=0A=
=0A=
=0A=
Thank you!=0A=
Regards=2C=0A=
Pintu Kumar=0A=
=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
