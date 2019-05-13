Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51DE0C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:27:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 139A72084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:27:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="KYEYMqia"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 139A72084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C9016B0005; Mon, 13 May 2019 13:27:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97A286B0008; Mon, 13 May 2019 13:27:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 869146B0010; Mon, 13 May 2019 13:27:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE086B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 13:27:02 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so9591457pgb.20
        for <linux-mm@kvack.org>; Mon, 13 May 2019 10:27:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=5iuLlyyOWz845CEoxjvFeDA6uM+p6rUh7ezrIXkoluc=;
        b=jNUL5A/MsuHODPXot7/0a9GFbeE0hL1zZemr6GDusRdFJp09vge2mL4jiU7LgMrMgM
         qzLPIDehbYL7Vypof4OeSwYrHK87sWi+Xlb54eB/30Mdo1LDOceGveaRuIttt4wBnUR+
         fMjeXEo5YcOAi5af5eVXHUzEPUu8iFxSoLnXVCrUVD4FMrkL1ybi15B7CFDD0N8UgqBJ
         2o3SSDLfFoI4yLJ5nbIItNbUZp/9bCHh/DIebbC7XmUn61xovtG+Q6JfmmGYss9gJmZo
         ZGMMljvzymyKTAW6WViDchKsBkki1zMfQIXdXM55Il4+B8bb1Ir8lyNIf8yNJfjKJJGN
         zbkA==
X-Gm-Message-State: APjAAAXoU5YSRgL6S+JtHg3bUvMFBt331oNmWQokqnxNk+TR8UUQYalr
	xid3BrV6oF7l5k49DYmrykfUToSYY7PJzsW8u7qLqOrlrx+QALRioebPhtkbfGha1e3lT5hvJwG
	pPoRD5jrs7XVG+4OL0CI8foBbgYJjEMMsgjOm8vVOekxiNurhDnz8Q+ImzdC1wh5iYg==
X-Received: by 2002:a62:304:: with SMTP id 4mr17301643pfd.186.1557768421998;
        Mon, 13 May 2019 10:27:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSvZMca8nFBQb0kcC3XAJqXtUb7R8kTcKd+IVR4dQGMDXk4Uktt3thS+20xNnwUOJX+zrw
X-Received: by 2002:a62:304:: with SMTP id 4mr17301551pfd.186.1557768421256;
        Mon, 13 May 2019 10:27:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557768421; cv=none;
        d=google.com; s=arc-20160816;
        b=xZXCh9w35K/kUCQ1tvtaLxOMeEENkNTlJMKsqV/9DeRkbKD+2XO294N+I06pwGCJs9
         y2xomVabt3Q6pYFwj2gwJ+q4c5Yj8XGvfZpPUojySopfxdLmFKoCHAit/eRDkBZQyrlg
         ElfXfHM6EZXBz3qhVsnf3NfgskEUiC/sbA7zPwaHj9JbKHruENAA25K4Z3VfMhsXoiYd
         dcb2e3Odo/d3TbaPLo2OlsnhGyR9chKwOEj2gahocwWQSniVGyxst8ycxOTv50C4whUG
         8Fl+hJ81JwRN/Aa8BZ+LCXOUcHxdrS+FzmzceO5aprFERjSwI14cIGUjVEO/fFMgiv2l
         2xrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=5iuLlyyOWz845CEoxjvFeDA6uM+p6rUh7ezrIXkoluc=;
        b=Rwoow+xCnNpHFYfNOtfxbXi3LBRefuc6BcSCUntfQJzkFbGu0Tkd0kOlLscKCqraJq
         4tc95eYXZYvq7lrc6K/+T1wSEhTs9n/W5RCGD2PN3wS1hhnFpyYE65JdUdS0hA+ErxBF
         3nOSRosVsmgOREfv/BvUAlyfAwXbPfi+5tdxUulQH+7K+wFsH/p7ydcOgm7wtrbP1S3u
         7RFKVEdZwkteujg+O86p9w5tB2UyODZQODHZj3R7JeQGaBPuNLW/W9pDPAalKsFuwQtX
         f2obyo6xJZdcsHSM6p3UTAHTSq32d/x/vPAsKLT5bQYTME6Da1fd0Enq/FqeTFO4C/BW
         DQKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KYEYMqia;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id w16si17666586plp.185.2019.05.13.10.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 10:27:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KYEYMqia;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd9a8eb0000>; Mon, 13 May 2019 10:27:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 13 May 2019 10:27:00 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 13 May 2019 10:27:00 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 13 May
 2019 17:27:00 +0000
Subject: Re: [PATCH 0/5] mm/hmm: HMM documentation updates and code fixes
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, Matthew
 Wilcox <willy@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190512150832.GB4238@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <89c6ce48-190b-65df-7c35-a0eb0f5d936f@nvidia.com>
Date: Mon, 13 May 2019 10:26:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190512150832.GB4238@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557768427; bh=5iuLlyyOWz845CEoxjvFeDA6uM+p6rUh7ezrIXkoluc=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=KYEYMqiaFUWGmzf3uqRTE3CKf0u6MxnNhKf5pI+pHFvjypeWF8KWQTzcVWwQoag93
	 qpf7d2eBgg04VrJm3elH3119s8dRSdNRlKdqgM09VPSBimQBSoJv+YmGxacQVs12uM
	 LgKZRNgZ4cPHJHS4bZE65PFWPmGH6ZKNSFXr06e0aa/UQbx/smyDqfKaCJl2Lhp75+
	 7H2GykDVlleOBe/rqdpKIPJ9dvuPOLZ25UNInI7ov+W1oRSzT2cMBYWxqhfWAVxjSJ
	 7BkwemDz5kvzrpPh/qt4BaQqoPPnpfKCPB5ILknioJxCGHsvmHaTKOaMLcOzLPdP/v
	 PyclKZ3YFaJrQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/12/19 8:08 AM, Jerome Glisse wrote:
> On Mon, May 06, 2019 at 04:29:37PM -0700, rcampbell@nvidia.com wrote:
>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
>> I hit a use after free bug in hmm_free() with KASAN and then couldn't
>> stop myself from cleaning up a bunch of documentation and coding style
>> changes. So the first two patches are clean ups, the last three are
>> the fixes.
>>
>> Ralph Campbell (5):
>>    mm/hmm: Update HMM documentation
>>    mm/hmm: Clean up some coding style and comments
>>    mm/hmm: Use mm_get_hmm() in hmm_range_register()
>>    mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
>>    mm/hmm: Fix mm stale reference use in hmm_free()
>=20
> This patchset does not seems to be on top of
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-5.2-v3
>=20
> So here we are out of sync, on documentation and code. If you
> have any fix for https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-=
5.2-v3
> then please submit something on top of that.
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
>>
>>   Documentation/vm/hmm.rst | 139 ++++++++++++++++++-----------------
>>   include/linux/hmm.h      |  84 ++++++++++------------
>>   mm/hmm.c                 | 151 ++++++++++++++++-----------------------
>>   3 files changed, 174 insertions(+), 200 deletions(-)
>>
>> --=20
>> 2.20.1

The patches are based on top of Andrew's mmotm tree
git://git.cmpxchg.org/linux-mmotm.git v5.1-rc6-mmotm-2019-04-25-16-30.
They apply cleanly to that git tag as well as your hmm-5.2-v3 branch
so I guess I am confused where we are out of sync.

