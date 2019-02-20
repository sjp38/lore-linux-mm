Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4213C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:18:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 578E62146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:18:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kwt4AX6q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 578E62146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD6748E0045; Wed, 20 Feb 2019 18:18:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D85468E0002; Wed, 20 Feb 2019 18:18:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C73AA8E0045; Wed, 20 Feb 2019 18:18:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95B8D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:18:14 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id c67so16323145ywe.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:18:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jHmuXcTo/w6zTazajwVjPqQZf/gX3YgCX//I42wV+b8=;
        b=VSLpzXViADMfM+p4PNsBJw+M2NphQsQWClfeIMfbV/gBZNVtLwevxE6cWCHGzPYFi8
         u+Oxi4GuZ0alzho0PFMnt3/Tq2Ezy/CA+3XBLBIyCGwDzcoeBhiYuHXe4lSFCprP4HqM
         anOIHY/6uShN0PfgSrrzHftEZiqxpCTBs0R70f+lGTN6aQTfDloyZcLK3slMjWLlC+1m
         OTecVkufZoufCAw1Wxckh1A8QgyAgoo+CVV2OQblM001gUYH64u9iMwEYTTffMmNiUmE
         cn5dG/xW6RKIA+O04UuRQ1wi3t2DYvyNXggNe3Fra7VfZzhXcjf5cQhkMHPfM5Z76+ic
         3iKQ==
X-Gm-Message-State: AHQUAuabzzfL47HsXm0Dsaw7zodH64wtvQHUpDgqd/pdHW0gg8cQjyHa
	+m1kQJKpl7IQlizixne9U+nqVcuFLnr0cSLbm3SHk8E2bAbh6/296YiX7QR4X5ASb9Ug9Ti3+uf
	js7zAT94cqY8/c086cimq3sg6vQRcsTITGzvHw3qxy6RX9U5tc7U0jYOdDbwRGaXsHA==
X-Received: by 2002:a25:4e89:: with SMTP id c131mr30035866ybb.383.1550704694284;
        Wed, 20 Feb 2019 15:18:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZPn2vjk92ppdAqaN2PYXZVGpL8E1iqYc6TPWco0mDtGiI/UUNeI3UR4dD1Dk4CiNj3f3m
X-Received: by 2002:a25:4e89:: with SMTP id c131mr30035822ybb.383.1550704693581;
        Wed, 20 Feb 2019 15:18:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550704693; cv=none;
        d=google.com; s=arc-20160816;
        b=cf8EZBAUejYEiPtWxttgRKRn6Kb16vyzfVQptSZWn9SoqwZds9V2rfk3xBTwDy1PCX
         g7gXELxkEC952Gajg3JETvuMfKGyEmNBhfMZQmWOldDwR1XK0mIpC7yDkrkEUEBsvxck
         8v3C9dbkW34bmaMnGkPjLuhDoRIcDQuPDXjGiPRVBK0KUsIeKKEkH4Om4lY+JkCyszZ2
         M2ZeH4NUEM7OwyzKvaYh0cMfhYC1CqSYJ7ZTfGFPMH0GVkUwLItghcqB4aWizMvzq4Ne
         OY6GRwE6cPP4XO7X6VlXGFolZVMZhJa4Bgeavzi+tpo00PAFhST69EQU901Kpz1clf+S
         JhXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jHmuXcTo/w6zTazajwVjPqQZf/gX3YgCX//I42wV+b8=;
        b=VYofkdjqPvBAxCXx8OHpWotM76pL4u5FZEQU1qUuMgI+9rBHVJNlDjklyOsGoY2Olq
         eSMq8mfQ6gBXY37uBLvm18gPNPmI0JIHdSIv3audKGvPnfAzviOdsRI122j5SfnHlHS5
         9Lyoq3lZf0/a0oizejonu6pqVmB/pWyjUCKLuGEoVZfbwJThvka20eEXUoTC/kNfNUDW
         Q22v3K/66R2GPVnLqL4sd9G7yAz/n5aNHwDzwpY8EYsnmxWWz0Ov2bcCZIQPFijF0xj4
         Ekqrf7uvStB+b2cUD0wIBSvL3aSjA4oBWqBW1tEEa6tnrIpy9EmpS0GkzGZwfD9RDx7k
         0R1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kwt4AX6q;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v11si11813857ywc.10.2019.02.20.15.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:18:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kwt4AX6q;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6de03c0000>; Wed, 20 Feb 2019 15:18:20 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 15:18:12 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 15:18:12 -0800
Received: from [10.2.169.124] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 23:18:09 +0000
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, Jason
 Gunthorpe <jgg@mellanox.com>, Dan Williams <dan.j.williams@intel.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0dbf7e99-7db4-4d8b-ecca-60893c83a2a9@nvidia.com>
Date: Wed, 20 Feb 2019 15:17:58 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550704701; bh=jHmuXcTo/w6zTazajwVjPqQZf/gX3YgCX//I42wV+b8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=kwt4AX6q2Qh4NQ4bFbxpjB52vcSjridZ19MNug1EAyU126yrxegiwIExxhEADAnmi
	 zaruvMUbAHztcDFdWH0IJmMDn0d2lEORUVh5n7xevio8AMg2hIwYqOEWjfjYiKrFZA
	 OChl6P/AiXoHiTdm3fdr0J81cvBwmn5biRRLA85Qwlypdfb2nrSQOD79XP9E4Q706X
	 9NwJrY6ldS1/iCSBWeaXE/BskNEvIb0v/vArmQXWj1+5NrCWxUuny0DgTEpjFqT/PY
	 l5DrvnvckQulQNG/THILAEqQVR+5pcaBARc+SWnK5Na+dhxJOzYD1cHKEYj9H8z26B
	 lc9Qr3g9Fqmxw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> This patchset improves the HMM driver API and add support for hugetlbfs
> and DAX mirroring. The improvement motivation was to make the ODP to HMM
> conversion easier [1]. Because we have nouveau bits schedule for 5.1 and
> to avoid any multi-tree synchronization this patchset adds few lines of
> inline function that wrap the existing HMM driver API to the improved
> API. The nouveau driver was tested before and after this patchset and it
> builds and works on both case so there is no merging issue [2]. The
> nouveau bit are queue up for 5.1 so this is why i added those inline.
>=20
> If this get merge in 5.1 the plans is to merge the HMM to ODP in 5.2 or
> 5.3 if testing shows any issues (so far no issues has been found with
> limited testing but Mellanox will be running heavier testing for longer
> time).
>=20
> To avoid spamming mm i would like to not cc mm on ODP or nouveau patches,
> however if people prefer to see those on mm mailing list then i can keep
> it cced.
>=20
> This is also what i intend to use as a base for AMD and Intel patches
> (v2 with more thing of some rfc which were already posted in the past).
>=20

Hi Jerome,

Although Ralph has been testing and looking at this patchset, I just now
noticed that there hasn't been much public review of it, so I'm doing
a bit of that now. I don't think it's *quite* too late, because we're
still not at the 5.1 merge window...sorry for taking so long to get to
this.

Ralph, you might want to add ACKs or Tested-by's to some of these
patches (or even Reviewed-by, if you went that deep, which I suspect you
did in some cases), according to what you feel comfortable with?


thanks,
--=20
John Hubbard
NVIDIA

