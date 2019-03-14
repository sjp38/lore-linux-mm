Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5BBDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 06:29:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6055A217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 06:29:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6055A217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2C7B8E0003; Thu, 14 Mar 2019 02:29:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDC178E0001; Thu, 14 Mar 2019 02:29:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7CD58E0003; Thu, 14 Mar 2019 02:29:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9379F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:29:23 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y1so5142996pgo.0
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:29:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=QTzmYsYJSsYLbGgfQo9XgVcfbuQfyumfqHV9pmR1hk8=;
        b=LyIMPyLspubA17se1U5eIvPgmVWtnrc/noF4c+28UtNTnNQnOJoHAlwSo8htKvVF4b
         Me0goeYwD79yke8c1QfohnECAa0+gF3FK/tk1drR/3Ccw7+7xb0owqDVIZh8umtUMdsH
         D8e9Ra+JgL4UXRQg8NOt2TWoM7fpGzuXwFe8oKceZBaJ5S07NqorUCQkqnGaHt8Si6vp
         9jLstFAQFy8fLATegW/O2lY2CyN1in75iHAzNwXPz9T2IhrY3laN3z11VhIKs/gRn7/T
         k3B1UPUl/74oR63m6x6SH6mCdImcmEtwQHbmFDq4bjRwFhXszaqzZk1NJAr2z4/KLGD7
         xFgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWsy6OnW6HTligQuUod2/vumV30ec85jMJk5boKrKaxyCqcOR/E
	TXawB4vu43JMcihp0/DoPb3KIzsXhISpg1zzfCNxvKKsfBRS8B3WozTQFAPsoJdgXMngWxhBm45
	kUV3hnTp2+8cXqzTS6y8IzrR5O7U0JpEFNOMFEVlgfnpQBkRKi3HWHGxK0kMFKj15Lg==
X-Received: by 2002:a63:d256:: with SMTP id t22mr8771686pgi.108.1552544963176;
        Wed, 13 Mar 2019 23:29:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZeglxrKsXcUzPW+S/2LdMFl1a0HNBf0W27YHvtYSbwvrj8q4S5SQJwLM0Ek4kaibjrvSc
X-Received: by 2002:a63:d256:: with SMTP id t22mr8771642pgi.108.1552544962234;
        Wed, 13 Mar 2019 23:29:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552544962; cv=none;
        d=google.com; s=arc-20160816;
        b=ylLazJE/PEFbP+dRmDrb1MQItJqncCJFNe1lHg5iMjqEsS1wf5S0FwWjYy278d2IiI
         Otm5HeJxzhiN6oPrJXZfVAu2/Wq7+mzlCKTUrMEncizbqjp2TtazPPspbn9BNh/9MPXR
         jyDhAMSReBn35O3Y9kopGPipIrH9nSAJF7MCQdIBa2alqU+q2c4tCe7hcnfxUtavAY6q
         PPwvcmt5uWStmcUSYRWlFU/dG8E7lzsInVLUhEc3jaV+3nq1x5eINkAMYfAUgdmYr7uT
         ZZ8W5+MSkdwbeRjlgY6SbRfd4hVye01B207MG6fhW7NLVuDmmuX7+wwuCY75ROE/ulwe
         xteQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=QTzmYsYJSsYLbGgfQo9XgVcfbuQfyumfqHV9pmR1hk8=;
        b=nCX1kyz0lx0Y1QhIE90qw0iowPIRQxFOeNoqbeggwbQNIGk5SxP2NEVMNdA48xRfkW
         WaLizdFs1OgRNuFK3uUvkdh70D7Y+8YIQPXDMnPO4/snPu67FCMOxZFUiYeT+4jI0Adz
         tPpXuPrwcN+eMDqPrSGc9snoKBdIW1whu27k/aJbAEihcOpam5Nr9UAzrwGwqvqOf9QU
         Uex+FJbuXhITN1F0kbYJ7yrWNEJAxrrziMqkfPhNzgDnU+NPQb9l9C08qcqQ24dzvige
         +ZEQ+7xR7EFMUASmKkHl7yC3rSezBaaAzTGPyDON0xYP7Ubkz5s+TzM72yshynXuserf
         NCkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id j13si12639893pgb.37.2019.03.13.23.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 23:29:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x2E6T99R025732
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 14 Mar 2019 15:29:09 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2E6T9W4029992;
	Thu, 14 Mar 2019 15:29:09 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2E6SqEo006613;
	Thu, 14 Mar 2019 15:29:09 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-3338476; Thu, 14 Mar 2019 15:27:57 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0319.002; Thu,
 14 Mar 2019 15:27:56 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: zhong jiang <zhongjiang@huawei.com>
CC: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [Qestion] Hit a WARN_ON_ONCE in try_to_unmap_one when runing
 syzkaller
Thread-Topic: [Qestion] Hit a WARN_ON_ONCE in try_to_unmap_one when runing
 syzkaller
Thread-Index: AQHU2O0je1X84FRQ5UO03r19PzuDFKYKFWaA
Date: Thu, 14 Mar 2019 06:27:55 +0000
Message-ID: <20190314062757.GA27899@hori.linux.bs1.fc.nec.co.jp>
References: <5C87D848.7030802@huawei.com>
In-Reply-To: <5C87D848.7030802@huawei.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4B7AEFEF8D2342479BEA063B334FC83A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 13, 2019 at 12:03:20AM +0800, zhong jiang wrote:
...
>=20
> Minchan has changed the conditon check from  BUG_ON  to WARN_ON_ONCE in t=
ry_to_unmap_one.
> However,  It is still an abnormal condition when PageSwapBacked is not eq=
ual to PageSwapCache.
>=20
> But Is there any case it will meet the conditon in the mainline.
>=20
> It is assumed that PageSwapBacked(page) is true in the anonymous page,   =
This is to say,  PageSwapcache
> is false. however,  That is impossible because we will update the pte for=
 hwpoison entry.
>=20
> Because page is locked ,  Its page flags should not be changed except for=
 PageSwapBacked

try_to_unmap_one() from hwpoison_user_mappings() could reach the
WARN_ON_ONCE() only if TTU_IGNORE_HWPOISON is set, because PageHWPoison()
is set at the beginning of memory_failure().

Clearing TTU_IGNORE_HWPOISON might happen on the following two paths:

  static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
                                    int flags, struct page **hpagep)
  {
      ...
 =20
      if (PageSwapCache(p)) {
              pr_err("Memory failure: %#lx: keeping poisoned page in swap c=
ache\n",
                      pfn);
              ttu |=3D TTU_IGNORE_HWPOISON;
      }
      ...

      mapping =3D page_mapping(hpage);                                     =
                                     =20
      if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&       =
                                   =20
          mapping_cap_writeback_dirty(mapping)) {                          =
                                   =20
              if (page_mkclean(hpage)) {                                   =
                                   =20
                      SetPageDirty(hpage);                                 =
                                   =20
              } else {                                                     =
                                   =20
                      kill =3D 0;                                          =
                                     =20
                      ttu |=3D TTU_IGNORE_HWPOISON;                        =
                                     =20
                      pr_info("Memory failure: %#lx: corrupted page was cle=
an: dropped without side effects\n",
                              pfn);                                        =
                                   =20
              }                                                            =
                                   =20
      }                                                                    =
                                   =20
      ...

      unmap_success =3D try_to_unmap(hpage, ttu);
      ...

So either of the above "ttu |=3D TTU_IGNORE_HWPOISON" should be executed.
I'm not sure which one, but both paths show printk messages, so if you
could have kernel message log, that might help ...

Thanks,
Naoya Horiguchi=

