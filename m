Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA3FAC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 00:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86EB421900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 00:20:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OUWf6Gw+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86EB421900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108D86B0003; Thu, 21 Mar 2019 20:20:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B8B26B0006; Thu, 21 Mar 2019 20:20:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0F756B0007; Thu, 21 Mar 2019 20:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7E9B6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 20:20:57 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j184so478873pgd.7
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=Uz5tWnTog3rM6fg5Ngw8SgW9XsFI4Vq/7X9KTfiskDU=;
        b=eUX3T8mwC9f5l49lm24nq9J+NIKN7/hYldj9YRnAkLzJBGmqB+rZCFc84wbE+T4F9N
         pel+QNCqAXqnhcZU0vNDhNf3atKV0ig0pN0U/EsujUR7Assjn+7XoTpiyxsNjoNzdaRW
         y04XLFNmgMLaGvGwDlaQImXqCUDnvSOMn26IqqWllmIrNn8S7FCuflF5UqcAsS8oMD36
         0dQFs86Y5a4PsLlvoy67bQYxi7fgbYv7WqpGPg99O9t5LVSqfWNjLknV7OoumcZO+NBy
         22Nt9x++T02O4wDNnDSnThOEGgS8UQWsb9LsW6HjuvQFvbSKRoQmrlvKCNsGGZDOwhS+
         5b7g==
X-Gm-Message-State: APjAAAX/Y0lOBSH04XmE8mNEVW7pwU1gd8AKQ8GVow/QkhEmz6qwgKjm
	/HX0xn2f1J4OmdN5oBhz+GEIcGHj83LmHx80z0xJAI378k/tVxAWH7rohVIBfNEodr2h6FSyic1
	hWNcol6RyQ0+WJwncwlEMh0xV+AWGWJTB+z1wg24ogrKzuGbFyb+M9chfeaKP2rrFOw==
X-Received: by 2002:a17:902:14b:: with SMTP id 69mr6502513plb.216.1553214057378;
        Thu, 21 Mar 2019 17:20:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjrRs1Znp3XaAreY13gip62cZSDzgOFnc7hG4vHtSli6R7EvPzebs8qgw6ZDU+baqjIF8F
X-Received: by 2002:a17:902:14b:: with SMTP id 69mr6502477plb.216.1553214056552;
        Thu, 21 Mar 2019 17:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553214056; cv=none;
        d=google.com; s=arc-20160816;
        b=hvxcB7csj7RNS8jfysSwMlWW3pV828ZXHhmnOGiZZTemOe3Uc55/nLhVxcP7OnnzQx
         1mf3UwsGuCMw9A4NQomFtUcMz196nbTVNu2mCEiF0tK7DqJ2teu3ZtJatxkRJ/VzUvhr
         FDGd3rrcByS/ZqlPDuKdZuypBYKegA90njBRIQaDFhKJVhJskCAcP0Lif3kd87CmFUkY
         XOAqZ8B2U22NJByUKcXFBF1JZLMDoOlkdN3F3GpEbAT7bsHB2fM73WWUJIBMlLvE971Y
         E5mnqsDGAFjH6oaNBm6eHU975uPxF03YULArBsTCjcYXhHPZihJcVz+n1Ywe8sijezs+
         o6Sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=Uz5tWnTog3rM6fg5Ngw8SgW9XsFI4Vq/7X9KTfiskDU=;
        b=HNFQ5wo7x1UcGdANb1rYXy2qWvBaAc9w2gjNmRgvA0K2A4QfnteUaa7DR92x6jhhDE
         R94AwfFq+lUdlMEfhzF4YHEAZBGwjGBhdlHhwLm5lZrwxE/4o4mpRSmAJriUBHURzSoX
         bD5F6Tg2orCE+yU6nEOde4kNJcU5vZpwGO9BZTCkgSCGFylP0CZwpN1IMq+iJVYuHVjN
         7rJUybuXQpFCi5SwjkSZnSUQN9IIIKRCmcUQCikniZSkFsAUcwdUenR90btGvrNLwAIr
         8toShalX7dsK207ZdoZG9lWBcMrEky2ozCPghcPjT+MbEasDSGxFZ/vQg0EMaEVZNNiO
         0kAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OUWf6Gw+;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id t32si5332883pgl.7.2019.03.21.17.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 17:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OUWf6Gw+;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c942a660000>; Thu, 21 Mar 2019 17:20:54 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 21 Mar 2019 17:20:55 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 21 Mar 2019 17:20:55 -0700
Received: from [10.2.161.82] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 22 Mar
 2019 00:20:55 +0000
From: Zi Yan <ziy@nvidia.com>
To: Yang Shi <shy828301@gmail.com>
CC: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	<linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov"
	<kirill@shutemov.name>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko
	<mhocko@suse.com>, David Nellans <dnellans@nvidia.com>
Subject: Re: [PATCH 0/5] Page demotion for memory reclaim
Date: Thu, 21 Mar 2019 17:20:54 -0700
X-Mailer: MailMate (1.12.4r5614)
Message-ID: <2137A80F-CC90-411B-A1AF-A56384ADE0B8@nvidia.com>
In-Reply-To: <CAHbLzkrLyG-j8kRrrQ==4Y4LDDLubvXMF88muyzXWAQWKw1ZSw@mail.gmail.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
 <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
 <20190321223706.GA29817@localhost.localdomain>
 <CAHbLzkrLyG-j8kRrrQ==4Y4LDDLubvXMF88muyzXWAQWKw1ZSw@mail.gmail.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_9EF958FC-2C3D-4B16-B110-D853B6A94A0D_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553214054; bh=Uz5tWnTog3rM6fg5Ngw8SgW9XsFI4Vq/7X9KTfiskDU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=OUWf6Gw+d25DOwwrZFr8B4l1S5/2+gmyz3HbCPNqAa4MSiYXlu8ARZSYctb5BL2t/
	 ot9UPDdEwhPokhvRnzRvkMZGTa/7rIX2HalP7qeLEq5UZ4q4V3MVF2V0otnN3j/Alz
	 1oo0GfW0NYhgstx5oShsn30j1gfd27IHxez8PRV8bjFX1O3RbnQNqVRqKBjWHrvEiQ
	 foMCb7gqfL4DGkzr6W3WEl8KBVGvyVWwsF4qn2OQsED+Fax7AAU7J5mPSNabRKbHPl
	 PM9A8+UfV/UIUSZRotgE92fXx/k+BakJbniNn5JxvVvKK8n6+4ddCuv6B8v6kbxCTj
	 ZnLIxEnIuIFSg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_9EF958FC-2C3D-4B16-B110-D853B6A94A0D_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 21 Mar 2019, at 16:02, Yang Shi wrote:

> On Thu, Mar 21, 2019 at 3:36 PM Keith Busch <keith.busch@intel.com> wro=
te:
>>
>> On Thu, Mar 21, 2019 at 02:20:51PM -0700, Zi Yan wrote:
>>> 1. The name of =E2=80=9Cpage demotion=E2=80=9D seems confusing to me,=
 since I thought it was about large pages
>>> demote to small pages as opposite to promoting small pages to THPs. A=
m I the only
>>> one here?
>>
>> If you have a THP, we'll skip the page migration and fall through to
>> split_huge_page_to_list(), then the smaller pages can be considered,
>> migrated and reclaimed individually. Not that we couldn't try to migra=
te
>> a THP directly. It was just simpler implementation for this first atte=
mpt.
>>
>>> 2. For the demotion path, a common case would be from high-performanc=
e memory, like HBM
>>> or Multi-Channel DRAM, to DRAM, then to PMEM, and finally to disks, r=
ight? More general
>>> case for demotion path would be derived from the memory performance d=
escription from HMAT[1],
>>> right? Do you have any algorithm to form such a path from HMAT?
>>
>> Yes, I have a PoC for the kernel setting up a demotion path based on
>> HMAT properties here:
>>
>>   https://git.kernel.org/pub/scm/linux/kernel/git/kbusch/linux.git/com=
mit/?h=3Dmm-migrate&id=3D4d007659e1dd1b0dad49514348be4441fbe7cadb
>>
>> The above is just from an experimental branch.
>>
>>> 3. Do you have a plan for promoting pages from lower-level memory to =
higher-level memory,
>>> like from PMEM to DRAM? Will this one-way demotion make all pages sin=
k to PMEM and disk?
>>
>> Promoting previously demoted pages would require the application do
>> something to make that happen if you turn demotion on with this series=
=2E
>> Kernel auto-promotion is still being investigated, and it's a little
>> trickier than reclaim.
>
> Just FYI. I'm currently working on a patchset which tries to promotes
> page from second tier memory (i.e. PMEM) to DRAM via NUMA balancing.
> But, NUMA balancing can't deal with unmapped page cache, they have to
> be promoted from different path, i.e. mark_page_accessed().

Got it. Another concern is that NUMA balancing marks pages inaccessible
to obtain access information. It might add more overheads on top of page =
migration
overheads. Considering the benefit of migrating pages from PMEM to DRAM
is not as large as =E2=80=9Cbring data from disk to DRAM=E2=80=9D, the ov=
erheads might offset
the benefit, meaning you might see performance degradation.

>
> And, I do agree with Keith, promotion is definitely trickier than
> reclaim since kernel can't recognize "hot" pages accurately. NUMA
> balancing is still corse-grained and inaccurate, but it is simple. If
> we would like to implement more sophisticated algorithm, in-kernel
> implementation might be not a good idea.

I agree. Or hardware vendor, like Intel, could bring more information
on page hotness, like multi-bit access bits or page-modification log
provided by Intel for virtualization.



--
Best Regards,
Yan Zi

--=_MailMate_9EF958FC-2C3D-4B16-B110-D853B6A94A0D_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlyUKmYPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKleMP/RceC2q7vQiOE19ilpxcSX4iAX7dUwtbkZg0
YVrSR3WceWx6L62+6B9RYCGPZEnMYGm1UJFKG+wBAO7QsWv11lt1baBqtNn6ORSX
tvgRMOVNW65YfCy/6vciv+nRuLkK/87aOF2nfie+RUIv6yt+KK0sWm1qN0x6vvHH
AXNXNSz0yUpcJqOhktVOCyAdLcI16afxmLdYDReOpMinToKySZVUswpA/BMoX/qP
zUH/96JflS5p8QGs07A8M1kGxG9shQldIEQIkbuOy3JuqAA4dr7q3mB9Kz3RKgwg
iPKMpEFEZWmwSJfYFrr/frlwlua3HP+NHpfvlP3lZQJcFUyB2TAIkIbUtsZcDJ9R
Z2Nb4CEE8MDusB3Fqg3KQE9cGJ++PFAA+QN2Y8UNBngi1Gcpjxxxd5JSdjI27R2c
xRrYZQy6BYW3WgMg+jKq/Gjf2PHRal+KDV+ttuxTFp6pPMJpdt3MdylptI8it8jZ
ro5yeu6yeV+fe9QkvlTrRKcvndSwANvx/H9ZWRdwKiHAnWWxChzq2fRaezOjNLzP
VB+8/5uST6eg5+r/Z7TIkkwOT9mNjrxfgRqW6jRTMOe15JAJlzh1Za9REQgCQtLI
HxvHdp0z0JkFBLwrtWCFkHeJsJ1vs7r6Red1h1ZjDYwHWH1OQ3X7qml6P1DzyFtY
qFY2/Suf
=+UmC
-----END PGP SIGNATURE-----

--=_MailMate_9EF958FC-2C3D-4B16-B110-D853B6A94A0D_=--

