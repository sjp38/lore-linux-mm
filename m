Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E0C4C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:46:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F72C23F61
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:46:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MkI1d9HH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F72C23F61
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3A66B0266; Wed, 29 May 2019 14:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4146B026A; Wed, 29 May 2019 14:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B9C06B026B; Wed, 29 May 2019 14:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 630BD6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:46:00 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a22so1537846otr.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:46:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:user-agent:content-language
         :mime-version:message-id:date:from:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=Up1cNIFFuc0gcQ797CpxaLKPJsnQBzZUtc04vOlvi54=;
        b=ly7r4MYm+5ici/d8kVaCvaNoU73vV/k75eEOL/ae/sZYqc2SJe/Vsi7w+gn8oFmiZP
         qSbIpS2M5T7BBkRq7ypvjcYbv1tFC2FOBQrgScRCCth20GIhA7sm4X+O0DLDU/+xJGoj
         /ubdyO08qZLIQJ9VbxvGrUADKr8Lc7ArJTwg4+SUmJgswLlSFCS8rbjUgk0IdjD++y2/
         93KatLSMa/+xhUq6vME2l4TlYU9i4qeenTL43UBEQoe4vt8k9Bfv/u9YTWKf52YGKPVN
         NwB5fAPbTHdrch0eG4W7vKb6EgnOWA8/vBFLGTM/BjLTkNxX0x2IKeC0vBlZ8ZlalAJ8
         PCSw==
X-Gm-Message-State: APjAAAWAY6a4PG2N+ZycMcqgs/e7c7D0sj9/3L+xgdk3EURPbze5VyKN
	s0JrvSO+OpWhF3PlI8j7mI/ae7T6KEg56k9mYbrZF9+33AtdYC9nARnXtb2HvpIpkhXfAmK9xg+
	OUXyvuxInbOfkWC49N/23JAcuuMjdw2M//OFxbb2v1hqAAhjd4WCNetztNrkMRgvKgg==
X-Received: by 2002:aca:1014:: with SMTP id 20mr6860352oiq.105.1559155559961;
        Wed, 29 May 2019 11:45:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1OpmQ4phvMbkPPE4ltTyrKA6MN6a6yJ4rbOykbHMaNzIYykzAMOGHYt/1wbnRDl/KUFkr
X-Received: by 2002:aca:1014:: with SMTP id 20mr6860320oiq.105.1559155559148;
        Wed, 29 May 2019 11:45:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559155559; cv=none;
        d=google.com; s=arc-20160816;
        b=z9Js5wloxINTz+PLWJ4lFh8AvpWJFbZhHqgVRFF3mvD0RUYCZ0oUHVYVrQLK/Jbwil
         GMdyz/WQTaUkD0KEL96K8+e1g/R48IzPuQftbC/g5IChZ4ShHShPOUWfzFXFa4U3ZBbH
         /u+/x1wLgOTU6dQfcZj9fqBpdgN0iHIg6+gve3ALmQNGjcOG4Ch09c+6j5WpDMdr4jUi
         H8UPLBaKirXQrAqWT9spiez72hojQ55xl7pbhlF1MdMuhR/rE1pIk9RGLaQvFNvs3FAV
         qQOdqdO9rLptZURppeSeSXWxltBey0cWHj0d9qBvncuvwZpQ2C+zvyqZj1ziKojKIbTM
         T+pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to:from
         :date:message-id:mime-version:content-language:user-agent
         :dkim-signature;
        bh=Up1cNIFFuc0gcQ797CpxaLKPJsnQBzZUtc04vOlvi54=;
        b=N4qu3dK20SC2NEjEr0vRTntYghrv1wi9FyRcwNm5JUCDOPwIy3BZ+ZH41ddZrPhlfv
         ZhH7ycXxLDcIwc+L4m8avD7ikAPZdnBpmlw/qdbhStL7SmQdJaGYteY8Yir/+3b8kUfE
         joE5VVC6WZYNemxmFUJFqptFhs4WXs6dNeavxtSg6QDwQd4pxKfHwxrWbZntiMMF6+mp
         jadGhpQhwo2a7AvKVIWk1kNIcvGKKbGao8uBrR/4TRdAzNw9HXGZbxA8LJZJ6lgdCPjt
         2FrKMendNcxtoa3cZqomx0lbA1BXbVhHR8NPmkMorJWyReUTIuxU4Ots/Eo4uGBI7IK/
         S9AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MkI1d9HH;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g5si88256oti.207.2019.05.29.11.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:45:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MkI1d9HH;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TIhrIS067356;
	Wed, 29 May 2019 18:45:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=mime-version :
 message-id : date : from : to : cc : subject : references : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Up1cNIFFuc0gcQ797CpxaLKPJsnQBzZUtc04vOlvi54=;
 b=MkI1d9HHwYgDzT6yM0ArD2VvvJiVyJKogI3qHgMF5OOb6TnaxCvoh1YuSLdW+nBIqERC
 U1SYmdCwrcXdlol6VeT+n+mx9DLHBBJBIcCl6rsHhYMvJOVTpiRJsYuATL/ydWy38yHa
 aXWEvLqnZlAv+mNnRq0Dzm18CHEDldJe0y3IsVOoxV8u3XI/ZRmzotN7PNTUcjSeAP5h
 B6JIHb2Z8/LRzle5FbDPk15hARZ57J65H7aksS8TtquiU2xqcuflhb1jJtO+7Arkcyub
 N5l/kHvnr7jRk+Vu8oXxHuLWYkYiom6mteVeM63Rsr4+EOJspR6aon/BCv9KTg4BFlK6 uQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2spxbqbr4x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 18:45:48 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TIi2Uu062527;
	Wed, 29 May 2019 18:45:48 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2sr31ved92-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 18:45:48 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4TIjihN008886;
	Wed, 29 May 2019 18:45:44 GMT
Received: from [192.168.1.222] (/71.63.128.209) by default (Oracle Beehive
 Gateway v4.0) with ESMTP ; Wed, 29 May 2019 11:44:52 -0700
USER-AGENT: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
Content-Language: en-US
MIME-Version: 1.0
Message-ID: <81a37f9c-4a85-c18d-b882-f361c4998d45@oracle.com>
Date: Wed, 29 May 2019 11:44:50 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko
 <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com,
        "Chen, Jerry T"
 <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1] mm: hugetlb: soft-offline: fix wrong return value of
 soft offline
References: <1558937200-18544-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1558937200-18544-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905290121
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9272 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905290121
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/26/19 11:06 PM, Naoya Horiguchi wrote:
> Soft offline events for hugetlb pages return -EBUSY when page migration
> succeeded and dissolve_free_huge_page() failed, which can happen when
> there're surplus hugepages. We should judge pass/fail of soft offline by
> checking whether the raw error page was finally contained or not (i.e.
> the result of set_hwpoison_free_buddy_page()), so this behavior is wrong.
> 
> This problem was introduced by the following change of commit 6bc9b56433b76
> ("mm: fix race on soft-offlining"):
> 
>                     if (ret > 0)
>                             ret = -EIO;
>             } else {
>     -               if (PageHuge(page))
>     -                       dissolve_free_huge_page(page);
>     +               /*
>     +                * We set PG_hwpoison only when the migration source hugepage
>     +                * was successfully dissolved, because otherwise hwpoisoned
>     +                * hugepage remains on free hugepage list, then userspace will
>     +                * find it as SIGBUS by allocation failure. That's not expected
>     +                * in soft-offlining.
>     +                */
>     +               ret = dissolve_free_huge_page(page);
>     +               if (!ret) {
>     +                       if (set_hwpoison_free_buddy_page(page))
>     +                               num_poisoned_pages_inc();
>     +               }
>             }
>             return ret;
>      }
> 
> , so a simple fix is to restore the PageHuge precheck, but my code
> reading shows that we already have PageHuge check in
> dissolve_free_huge_page() with hugetlb_lock, which is better place to
> check it.  And currently dissolve_free_huge_page() returns -EBUSY for
> !PageHuge but that's simply wrong because that that case should be
> considered as success (meaning that "the given hugetlb was already
> dissolved.")

Hello Naoya,

I am having a little trouble understanding the situation.  The code above is
in the routine soft_offline_huge_page, and occurs immediately after a call to
migrate_pages() with 'page' being the only on the list of pages to be migrated.
In addition, since we are in soft_offline_huge_page, we know that page is
a huge page (PageHuge) before the call to migrate_pages.

IIUC, the issue is that the migrate_pages call results in 'page' being
dissolved into regular base pages.  Therefore, the call to
dissolve_free_huge_page returns -EBUSY and we never end up setting PageHWPoison
on the (base) page which had the error.

It seems that for the original page to be dissolved, it must go through the
free_huge_page routine.  Once that happens, it is possible for the (dissolved)
pages to be allocated again.  Is that just a known race, or am I missing
something?

> This change affects other callers of dissolve_free_huge_page(),
> which are also cleaned up by this patch.

It may just be me, but I am having a hard time separating the fix for this
issue from the change to the dissolve_free_huge_page routine.  Would it be
more clear or possible to create separate patches for these?

-- 
Mike Kravetz

