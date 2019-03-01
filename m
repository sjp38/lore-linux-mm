Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EBFAC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 07:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F19082186A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 07:31:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F19082186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F65D8E0003; Fri,  1 Mar 2019 02:31:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A5898E0001; Fri,  1 Mar 2019 02:31:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46C918E0003; Fri,  1 Mar 2019 02:31:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1956A8E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 02:31:32 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id 31so10709215ota.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 23:31:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=JNlGtuscMN5SghMjfvqjDhhAHVESklrSThT7DUnj2Us=;
        b=HZXuMvQ9Gm1SF1W/8aRohxBNWwn81sFVx8EL3fvDxQcS9EdY/HbsYIxwZ5j2Q6Gp/b
         iwkSIbYbqSc9RMkjTVmolmUqgioucMSUzeOt+FDqWPEHECbA9INsyskX/NlynXQawsTO
         nL/3Gk5n/e2E/zDeHWn0OtwwFXqrBpRmyRcy0HQFAGMcprl7Z2MxOcgJ/8CpiRFCoYRa
         dkT0PTnYoZmIvQiBtl0w/XBMPOqyjdr0+zmw9JGyYDq3atbmmT0k7pZn8Jad7cONm2ui
         erimrkrfLk2QUl2nHG5c+QVc+vAQZ7OcOkUlQSspu/IUWVpeaDpo6Va1vnkYf2SiTgKQ
         RvDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: AHQUAuZ0aRCcKxD9lEW/6saSRmXcVnCno6HhKYpMYvT0bLrJwVgnkhl8
	EK1qK67RLQQF+vj64ayrhB51Iw/LhdA4DxGYLL5ytYXnwfZCjuYb8YGQbTtu9jSbebO9Ex/Zkcg
	a//NzTuJyzC4jfGiNL0BbNsc9cfGz0HB+zoScSHhZ7xB4jRibiumVWVck8qxOqXtI1Q==
X-Received: by 2002:aca:e109:: with SMTP id y9mr2347516oig.146.1551425491655;
        Thu, 28 Feb 2019 23:31:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYo45kBa3TOtY4ptR9m9kGK3MCczdHgoHGsrPwTE9dapQOp4gB/t+PPZYewXKYF9khhLVTN
X-Received: by 2002:aca:e109:: with SMTP id y9mr2347462oig.146.1551425490366;
        Thu, 28 Feb 2019 23:31:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551425490; cv=none;
        d=google.com; s=arc-20160816;
        b=VnPlwsU9jJLOunHwgegbfk3eoGnyyxVPq85WDTS8+cpQaX42qqVPskZm9s1t90dDE/
         ElqckJwMPU5gM2h5KTKFp3iW6KujqNTKsZFhmpFrEbR1/BUWTe/pNMNE1HBvG3ZEbS54
         /SeMwoZio6TfE7bQlmsxU21c3AJZNWjR8FQ1MTcx81/RleOljSlNRAcgAMYk/OVQGd6a
         1v5I9+55QsHICSBo/aCubWdFTbFJXo/rJYD0JQZlhgTE7VEJCvno+aKiATVRJpv1FRn1
         rqlVZl2myta+Otxg9B8QR1xPvg8ekUn/lpRH958PZMHUitbbK3Ctk/d5+SO7293EABLj
         oOjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=JNlGtuscMN5SghMjfvqjDhhAHVESklrSThT7DUnj2Us=;
        b=BKhki7CDv1nuTjBrguvfia43eISvQtiiytcUed3MhHgUNWBqbweCi8hJeV+zzhXUDP
         AbwtRzorS3tNzLzzNEgHDcHsAaEh2BuoPh36zPp85f7brI/UveC5I9YprlKthKcG/sxI
         sHT8XPLF6OxnkAau7lFwh2V4xZ9qdSjuye3oX51coYlVepNXwu7mXzPdtqdd1ehPlEFj
         bvVeGfF4VuyKiAW4jVy0cMlvzaJQ1DDrPaJ9fxq0nhK5SiWyrwNQkiPK9K5VTH/YWGTn
         1oLHWYibicb3Eqq9kgF0NkvzNtivaAl4KqtFuKsJ/Y/GomfN3gIN4JVyfkKblLkS0RUP
         g02A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id w131si7999884oie.171.2019.02.28.23.31.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 23:31:30 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x217VEUe007072
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 1 Mar 2019 16:31:14 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x217VEAQ029944;
	Fri, 1 Mar 2019 16:31:14 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x217VEvO005275;
	Fri, 1 Mar 2019 16:31:14 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-2937063; Fri, 1 Mar 2019 16:29:21 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0319.002; Fri, 1
 Mar 2019 16:29:20 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: zhong jiang <zhongjiang@huawei.com>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mhocko@suse.com" <mhocko@suse.com>,
        "hughd@google.com" <hughd@google.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hwpoison: fix thp split handing in
 soft_offline_in_use_page()
Thread-Topic: [PATCH] mm: hwpoison: fix thp split handing in
 soft_offline_in_use_page()
Thread-Index: AQHUzcUNc4KTTJZZrEmx16Y+65H3QaXxgnUAgAAL5wCABEAwgA==
Date: Fri, 1 Mar 2019 07:29:19 +0000
Message-ID: <20190301072919.GA3027@hori.linux.bs1.fc.nec.co.jp>
References: <1551179880-65331-1-git-send-email-zhongjiang@huawei.com>
 <20190226135156.mifspmbdyr6m3hff@kshutemo-mobl1>
 <5C754E78.4050804@huawei.com>
In-Reply-To: <5C754E78.4050804@huawei.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.148]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <151577097361A14A801F1E3D561D1638@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 10:34:32PM +0800, zhong jiang wrote:
> On 2019/2/26 21:51, Kirill A. Shutemov wrote:
> > On Tue, Feb 26, 2019 at 07:18:00PM +0800, zhong jiang wrote:
> >> From: zhongjiang <zhongjiang@huawei.com>
> >>
> >> When soft_offline_in_use_page() runs on a thp tail page after pmd is p=
lit,
> > s/plit/split/
> >
> >> we trigger the following VM_BUG_ON_PAGE():
> >>
> >> Memory failure: 0x3755ff: non anonymous thp
> >> __get_any_page: 0x3755ff: unknown zero refcount page type 2fffff800000=
00
> >> Soft offlining pfn 0x34d805 at process virtual address 0x20fff000
> >> page:ffffea000d360140 count:0 mapcount:0 mapping:0000000000000000 inde=
x:0x1
> >> flags: 0x2fffff80000000()
> >> raw: 002fffff80000000 ffffea000d360108 ffffea000d360188 00000000000000=
00
> >> raw: 0000000000000001 0000000000000000 00000000ffffffff 00000000000000=
00
> >> page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) =3D=3D 0)
> >> ------------[ cut here ]------------
> >> kernel BUG at ./include/linux/mm.h:519!
> >>
> >> soft_offline_in_use_page() passed refcount and page lock from tail pag=
e to
> >> head page, which is not needed because we can pass any subpage to
> >> split_huge_page().
> > I don't see a description of what is going wrong and why change will fi=
xed
> > it. From the description, it appears as it's cosmetic-only change.
> >
> > Please elaborate.
> When soft_offline_in_use_page runs on a thp tail page after pmd is split,=
 =20
> and we pass the head page to split_huge_page, Unfortunately, the tail pag=
e
> can be free or count turn into zero.

I guess that you have the similar fix on memory_failure() in your mind:

  commit c3901e722b2975666f42748340df798114742d6d
  Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
  Date:   Thu Nov 10 10:46:23 2016 -0800
 =20
      mm: hwpoison: fix thp split handling in memory_failure()

So it seems that I somehow missed fixing soft offline when I wrote commit
c3901e722b29, and now you find and fix that. Thank you very much.
If you resend the patch with fixing typo, can you add some reference to
c3901e722b29 in the patch description to show the linkage?
And you can add the following tags:

Fixes: 61f5d698cc97 ("mm: re-enable THP")
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi=

