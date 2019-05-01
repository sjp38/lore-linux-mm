Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10CF6C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 10:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACE5B21670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 10:33:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACE5B21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A0B86B0005; Wed,  1 May 2019 06:33:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5516C6B0006; Wed,  1 May 2019 06:33:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44BC86B0007; Wed,  1 May 2019 06:33:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 196456B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 06:33:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5so10698227pgk.9
        for <linux-mm@kvack.org>; Wed, 01 May 2019 03:33:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version
         :content-transfer-encoding;
        bh=NE/e8S6yVOHYr45xl7ghh5QfgpBa7EZjiyjE2pu3nUc=;
        b=baRd/9bkEtiGOx9BCzCeTF3PCkNmpBldYcsw6jQ6xqa9fJ6DLAsIcchZP/HDYvL5Cn
         Tb98FVbguCRgKQhsVZ1QcaBUV3a73iLWfew2Mu8d3hcDlndY5sLYJK8NYHF6haWc3cV2
         MeI2fmJ6w8Txp50Q369O7A3hTiTHJh3eN+CsTcty5CsGHuu39BujGXr/JFOX4RjMUs8b
         r7RyVUdtlLR/1rIHWIRswfkIfdMUyqXCUM+aX1DFPnPzC8j3uiy/oS+jxz8BpVstCXHy
         b7zdO5hoB/0DEWtrgceRrQSzMbmtmrTcD5qw5SGIrfx+4Sthig1CiKK9BWrlhNF5ahQR
         QTUw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAWlID8SmAO4h296B3A0iZUfQ//QXWlnBGqvHUJ5m/3vE6mgJn9D
	xZFojLaeebWouFxFTH6KtHIgTnw44o1NbBqEJOUeNFBsn8qTIvCHqOFu4c+XlPGESFzUujTn3Z6
	HAyO+BrZPKLcv29HKTl9H/3ycOAGE5G7WE9D/meAM11P4Qx5p+S7APiv+vxxHcoc=
X-Received: by 2002:a17:902:8bca:: with SMTP id r10mr30788405plo.67.1556706781781;
        Wed, 01 May 2019 03:33:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZaUfaMfxS92fXsfuZFfgf2xCmdfj9cFTf0fbEMJ6IM7UWQtqybVRvjNedczNg524fS/YS
X-Received: by 2002:a17:902:8bca:: with SMTP id r10mr30788331plo.67.1556706780862;
        Wed, 01 May 2019 03:33:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556706780; cv=none;
        d=google.com; s=arc-20160816;
        b=wzQo5i+ETGCplEnlUILlK+veoxqq/Mry2f2MJ81698ML2RhLObK1de6eNm/eO9nui3
         OGoP641xtjjYnZNmoxU+rWWzT8CDIK267pmGkb6o4mHRJH45VNIRWdUOfdkEURIbDSMQ
         CFpILAoV+gY3UWrJXE8bNRc0lGU9OJ29tLQcFsziwTi/cePDdMBiHugiVtn7lRdizlCf
         McQmezotB5zJDDVC1PujfuHJlRJLJtlZat9z2Loq7pHSmGag/QcJDFjZGnR5kA7X7YQe
         SbusWh7diO+Zfb2Yw4S1yFGtLX1BF/rc5fN4FrpZsK06HJdiHxTJkQlXCBDr24uPYNJs
         bA2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from;
        bh=NE/e8S6yVOHYr45xl7ghh5QfgpBa7EZjiyjE2pu3nUc=;
        b=ZjVynXxx42EL9fYMhLv5AFm591Ai98whCMy00XgRVV1dXEKr7HXTfltDaRtzFlDkcn
         SQDFVxILXIdv4zM3DFHKaXkO66oq228Vj1+ElEgLpL1xH9F3h+i+YZGHfNUGRnzXoU7F
         ze3U7u8rR5T+gXK1wnEU5RQcSMQnW8JgdxONnsCTLvz30YJ4Vtaj2+R5sFGcEn9RWuMg
         iwULFq327JT/wPz8iRwVUzCMfvtUOcPsUzLRB5f2m5/EiZC8uM6NB3bMM4u6FNglY2cs
         +HfMwXWfQyFOHo+hXGS3VLIDORR5JQDtDav0owUQoYqqYQlQC9YKxS1eEBOYr/0zZw34
         3Ptg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id s20si38981628pgs.509.2019.05.01.03.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 03:33:00 -0700 (PDT)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44vF8m5zk3z9s9N;
	Wed,  1 May 2019 20:32:56 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com, vbabka@suse.cz, luto@amacapital.net, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, stable@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
In-Reply-To: <4e1bbb14-e14f-8643-2072-17b4cdef5326@linux.vnet.ibm.com>
References: <20190401141549.3F4721FE@viggo.jf.intel.com> <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de> <87d0lht1c0.fsf@concordia.ellerman.id.au> <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com> <4f43d4d4-832d-37bc-be7f-da0da735bbec@intel.com> <4e1bbb14-e14f-8643-2072-17b4cdef5326@linux.vnet.ibm.com>
Date: Wed, 01 May 2019 20:32:55 +1000
Message-ID: <87k1faa2i0.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> Le 23/04/2019 =C3=A0 18:04, Dave Hansen a =C3=A9crit=C2=A0:
>> On 4/23/19 4:16 AM, Laurent Dufour wrote:
...
>>> There are 2 assumptions here:
>>>   1. 'start' and 'end' are page aligned (this is guaranteed by __do_mun=
map().
>>>   2. the VDSO is 1 page (this is guaranteed by the union vdso_data_stor=
e on powerpc)
>>=20
>> Are you sure about #2?  The 'vdso64_pages' variable seems rather
>> unnecessary if the VDSO is only 1 page. ;)
>
> Hum, not so sure now ;)
> I got confused, only the header is one page.
> The test is working as a best effort, and don't cover the case where=20
> only few pages inside the VDSO are unmmapped (start >=20
> mm->context.vdso_base). This is not what CRIU is doing and so this was=20
> enough for CRIU support.
>
> Michael, do you think there is a need to manage all the possibility=20
> here, since the only user is CRIU and unmapping the VDSO is not a so=20
> good idea for other processes ?

Couldn't we implement the semantic that if any part of the VDSO is
unmapped then vdso_base is set to zero? That should be fairly easy, eg:

	if (start < vdso_end && end >=3D mm->context.vdso_base)
		mm->context.vdso_base =3D 0;


We might need to add vdso_end to the mm->context, but that should be OK.

That seems like it would work for CRIU and make sense in general?

cheers

