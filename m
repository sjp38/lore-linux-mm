Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6626B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 03:36:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so48760995wmu.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 00:36:35 -0700 (PDT)
Received: from mx0b-0016f401.pphosted.com (mx0b-0016f401.pphosted.com. [67.231.156.173])
        by mx.google.com with ESMTPS id be6si16123940wjb.31.2016.08.10.00.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 00:36:34 -0700 (PDT)
From: Yehuda Yitschak <yehuday@marvell.com>
Subject: RE: [QUESTION] mmap of device file with huge pages
Date: Wed, 10 Aug 2016 07:36:29 +0000
Message-ID: <ca84d8e02a0942c39ad0da01a1fe43f1@IL-EXCH02.marvell.com>
References: <85d8c7bb8bcc4a30865a4512dd174cf8@IL-EXCH02.marvell.com>
 <57AA155B.70009@intel.com>
In-Reply-To: <57AA155B.70009@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Shadi Ammouri <shadi@marvell.com>



> -----Original Message-----
> From: Dave Hansen [mailto:dave.hansen@intel.com]
> Sent: Tuesday, August 09, 2016 20:40
> To: Yehuda Yitschak; linux-mm@kvack.org
> Cc: Shadi Ammouri
> Subject: Re: [QUESTION] mmap of device file with huge pages
>=20
> On 08/09/2016 02:58 AM, Yehuda Yitschak wrote:
> > I would appreciate any advice on this issue
>=20
> This is kinda a FAQ at this point. =20

Sorry for posting a FAQ but I found nothing on the web.
There's tons of general material about mmap, huge-pages and device files bu=
t nothing on this specific use case.
I posted this question since I suspected I might need a ugly hack for this =
scenario.
Is there any standard solution to this issue ?=20

> But, the thing I generally suggest is that you
> allocate hugetlbfs memory or anonymous transparent huge pages in your
> applciation via the _normal_ mechanisms, and then hand a pointer to that =
in
> to your driver.

Thanks. I can try that.
Once I hand the pointer to the driver, is there a standard API to map user-=
space memory to kernel space.

Thanks=20

Yehuda=20

>=20
> It's backwards from how you're doing it now, but it makes things easier d=
own
> the road.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
