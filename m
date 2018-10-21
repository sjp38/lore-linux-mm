Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEAC16B000E
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 03:30:26 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 30so16500094ota.15
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 00:30:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h9si12122921otl.322.2018.10.21.00.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 00:30:25 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9L7TL0v126195
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 03:30:24 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n8hb2dx2q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 03:30:24 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 21 Oct 2018 08:30:22 +0100
Date: Sun, 21 Oct 2018 10:30:16 +0300
In-Reply-To: <20181019081729.klvckcytnhheaian@master>
References: <1538067825-24835-1-git-send-email-rppt@linux.vnet.ibm.com> <20181019081729.klvckcytnhheaian@master>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] memblock: remove stale #else and the code it protects
From: Mike Rapoport <rppt@linux.ibm.com>
Message-Id: <6EEAA7EC-75B7-4899-A562-35A58FC037E6@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On October 19, 2018 11:17:30 AM GMT+03:00, Wei Yang <richard=2Eweiyang@gma=
il=2Ecom> wrote:
>Which tree it applies?

To mmotm of the end of September=2E

>On Thu, Sep 27, 2018 at 08:03:45PM +0300, Mike Rapoport wrote:
>>During removal of HAVE_MEMBLOCK definition, the #else clause of the
>>
>>	#ifdef CONFIG_HAVE_MEMBLOCK
>>		=2E=2E=2E
>>	#else
>>		=2E=2E=2E
>>	#endif
>>
>>conditional was not removed=2E
>>
>>Remove it now=2E
>>
>>Signed-off-by: Mike Rapoport <rppt@linux=2Evnet=2Eibm=2Ecom>
>>Reported-by: Alexander Duyck <alexander=2Eduyck@gmail=2Ecom>
>>Cc: Michal Hocko <mhocko@suse=2Ecom>
>>---
>> include/linux/memblock=2Eh | 5 -----
>> 1 file changed, 5 deletions(-)
>>
>>diff --git a/include/linux/memblock=2Eh b/include/linux/memblock=2Eh
>>index d3bc270=2E=2Ed4d0e01 100644
>>--- a/include/linux/memblock=2Eh
>>+++ b/include/linux/memblock=2Eh
>>@@ -597,11 +597,6 @@ static inline void early_memtest(phys_addr_t
>start, phys_addr_t end)
>> {
>> }
>> #endif
>>-#else
>>-static inline phys_addr_t memblock_alloc(phys_addr_t size,
>phys_addr_t align)
>>-{
>>-	return 0;
>>-}
>>=20
>> #endif /* __KERNEL__ */
>>=20
>>--=20
>>2=2E7=2E4

--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E
