Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4185B6B0268
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:16:06 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q8so9812606pfh.12
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:16:06 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id j3si5204333plk.506.2018.01.17.15.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 15:16:05 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [bug report] hugetlb, mempolicy: fix the mbind hugetlb migration
Date: Wed, 17 Jan 2018 23:15:03 +0000
Message-ID: <396fb669-3466-3c31-51a1-6c483351e0ce@ah.jp.nec.com>
References: <20180109200539.g7chrnzftxyn3nom@mwanda>
 <20180110104712.GR1732@dhcp22.suse.cz> <20180117121801.GE2900@dhcp22.suse.cz>
In-Reply-To: <20180117121801.GE2900@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BB08AE993B185041A4C14E2DCAE1E264@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>

On 01/17/2018 09:18 PM, Michal Hocko wrote:
> On Wed 10-01-18 11:47:12, Michal Hocko wrote:
>> [CC Mike and Naoya]
>=20
> ping
>=20
>> From 7227218bd526cceb954a688727d78af0b5874e18 Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Wed, 10 Jan 2018 11:40:20 +0100
>> Subject: [PATCH] hugetlb, mbind: fall back to default policy if vma is N=
ULL
>>
>> Dan Carpenter has noticed that mbind migration callback (new_page)
>> can get a NULL vma pointer and choke on it inside alloc_huge_page_vma
>> which relies on the VMA to get the hstate. We used to BUG_ON this
>> case but the BUG_+ON has been removed recently by "hugetlb, mempolicy:
>> fix the mbind hugetlb migration".
>>
>> The proper way to handle this is to get the hstate from the migrated
>> page and rely on huge_node (resp. get_vma_policy) do the right thing
>> with null VMA. We are currently falling back to the default mempolicy in
>> that case which is in line what THP path is doing here.

vma is used only for getting mempolicy in alloc_huge_page_vma(), so
falling back to default mempolicy looks better to me than BUG_ON.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
