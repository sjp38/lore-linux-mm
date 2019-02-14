Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 626BAC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E21E21916
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5MN0n8QW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E21E21916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B12618E0002; Thu, 14 Feb 2019 14:48:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC43D8E0001; Thu, 14 Feb 2019 14:48:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B2088E0002; Thu, 14 Feb 2019 14:48:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8E58E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:48:59 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id e5so5021207pgc.16
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:48:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=44ag5C0KnKZ9v0n5xm9kYXZ5oCu2l/oDOkg2NTBpUXI=;
        b=uFYOxQJAuI4b1X/uWA+TD3910grB09ZWCJBe7B7E3Xg2FzdaS1XfdxJUOzoSWnheKz
         nm3PsfYUenTYkMf4OhhTOQhgnd1rKFthmbgELxWnnIzw7ewVtkkrWJPKYC0FgJvhfC/4
         4jEXikeofv9ImKJ9GycyRpxY+ZL9zN94UmQrZ3M5lIo/57AB2rdfXjbgP/UeKBnZlbAi
         gLQ8US4xU6uteCHPtZgJmnhyCGtO3/3mwHF+oCcf5OneQlRHXaRK37k3TEL/BzKnh7ki
         ZOwC9JVv42xfJTpuoAdoiRr/XBV8iQurvWnSOS5kPCbtY1rd6uzpFPCBrVSd1tEHBZDk
         OPhw==
X-Gm-Message-State: AHQUAuZMNzvBB+cwbhjDO4oWayTUKRsx3nThNwtqWkk2OxkHk2x4PTmr
	HrINQBjYOpr1Q9/t5eH5JukUkFPahQxutP5ZBjILOrZ0UZBvOUMuLH5JXao0W+kk3ka4kPW7ngi
	7efZirpu0yNVxNMuYSNxfURjo1rxu4/IY3MJoJ/naWN9MebaUqvZ7VShE/aefNDXV7w==
X-Received: by 2002:a62:5301:: with SMTP id h1mr5747624pfb.17.1550173739022;
        Thu, 14 Feb 2019 11:48:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFGkH9ESawh7duBMwkKeH5faIx+uWMTkfz0sNSnb6PKvy5//OkzhLMiXpTTRG/ob/dYWf4
X-Received: by 2002:a62:5301:: with SMTP id h1mr5747576pfb.17.1550173738233;
        Thu, 14 Feb 2019 11:48:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550173738; cv=none;
        d=google.com; s=arc-20160816;
        b=sA4mtQKGnX54TgHoZlvXsq/DQvzp+t1R6yAl6+Ie9NjTWI9nT7spy2W9gOlrcpvNwv
         iNKmh3wgprIloUw9zOMPJjVVqijULpwgXDaXu0vf9narIkiygSCbrx5HwR8Y1vb4oZKA
         PPs3YuUnogLbjQMxQAtnaqoJ7K/rUDTJ+CbwhHUDO2XXfbMFcMjsk0LhFoSUfH2zPjyi
         8VwWFZMQ4xNKjFzyGmSqO+6J27Ef3veaLKI+Yh+wrBSXdVHEl5wFFGV87lgTrtqt/g/U
         BI2BmQb8WmqNY/ixJi0givU+N2ZKikzOxf7B4UMqUpNANFQjf/6qeXfjOwTH4N0eowj7
         tGNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=44ag5C0KnKZ9v0n5xm9kYXZ5oCu2l/oDOkg2NTBpUXI=;
        b=pJk2/kMHtF7us+a4cyl8oS19oWhX0CNFEA6dZqGNikNuEs8HpxtrVpQnV3bb66N4nb
         ZgjR2ItlVTvYcrZFDy5hGpCS5PEGFmQYAlcqNXnu5ABbfZTbqVFjoeSHCpa1BnYi2dUW
         ntKvRLV2WZJAosh48WmwIBp0Hf9/u/0YYpi2P61SWTIBRcIvj6bVsoIP6F8SA0HB77cT
         6JcXpTRmXXj4414Eci9UkrCUPU49C5NoFy+ixsfD+7/E5RJtJRtt/8xsevGrydwIXGWo
         MupAsUtgNjsG20j5J9uA84nXrZc1DE+UgdsKvvPv8HM2w/aKiK+8OqB8EBApTEw0RC/J
         ZEhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5MN0n8QW;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e2si3264460pfe.111.2019.02.14.11.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 11:48:58 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5MN0n8QW;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EJdiW7062012;
	Thu, 14 Feb 2019 19:48:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=44ag5C0KnKZ9v0n5xm9kYXZ5oCu2l/oDOkg2NTBpUXI=;
 b=5MN0n8QWLGoZiAIYHc+P1ljOzXm9A3NnlHqnj7fVjd0Yi71el8kU+50Iq1aqnXxxsf/7
 pa2Ikp4AhlO9jOPpDax8AkDG/KkluV3PlvtcmGaV5K7T/jqKsCkWegiw4CRT4Y1/zkM9
 YPp6d4nca/YPsxuLvPhs+YsoBJliCKJdVzdW7InGegAgZ/hYqBjsDFYNh8UzDqOXUwhC
 aX+cMXCZwycPE1ehXFcR0ZmpM6WMwOs1pStDgtxlP85SHpfzJKRELmhLDvYk7WepRAWh
 FNrOK+bYt9t/ef9+l8ALHCxhUm8RvKMica2GTeb8egXJzTt+0TE0KqoR5p/oqTDd5tyi /A== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qhre5t280-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:48:38 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1EJmVIO024689
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:48:31 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1EJmStY012916;
	Thu, 14 Feb 2019 19:48:28 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 19:48:28 +0000
Subject: Re: [RFC PATCH v8 04/14] swiotlb: Map the buffer if it was unmapped
 by XPFO
To: Christoph Hellwig <hch@lst.de>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
        catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
        konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <b595ffb3231dfef3c6b6c896a8e1cba0e838978c.1550088114.git.khalid.aziz@oracle.com>
 <20190214074747.GA10666@lst.de>
 <3c75c46c-2a5a-cd75-83d4-f77d96d22f7d@oracle.com>
 <20190214174451.GA3338@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <056ffba0-e970-96d5-3d0b-c0a6f9460405@oracle.com>
Date: Thu, 14 Feb 2019 12:48:25 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214174451.GA3338@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=891 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 10:44 AM, Christoph Hellwig wrote:
> On Thu, Feb 14, 2019 at 09:56:24AM -0700, Khalid Aziz wrote:
>> On 2/14/19 12:47 AM, Christoph Hellwig wrote:
>>> On Wed, Feb 13, 2019 at 05:01:27PM -0700, Khalid Aziz wrote:
>>>> +++ b/kernel/dma/swiotlb.c
>>>> @@ -396,8 +396,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr=
, phys_addr_t tlb_addr,
>>>>  {
>>>>  	unsigned long pfn =3D PFN_DOWN(orig_addr);
>>>>  	unsigned char *vaddr =3D phys_to_virt(tlb_addr);
>>>> +	struct page *page =3D pfn_to_page(pfn);
>>>> =20
>>>> -	if (PageHighMem(pfn_to_page(pfn))) {
>>>> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>>>
>>> I think this just wants a page_unmapped or similar helper instead of
>>> needing the xpfo_page_is_unmapped check.  We actually have quite
>>> a few similar construct in the arch dma mapping code for architecture=
s
>>> that require cache flushing.
>>
>> As I am not the original author of this patch, I am interpreting the
>> original intent. I think xpfo_page_is_unmapped() was added to account
>> for kernel build without CONFIG_XPFO. xpfo_page_is_unmapped() has an
>> alternate definition to return false if CONFIG_XPFO is not defined.
>> xpfo_is_unmapped() is cleaned up further in patch 11 ("xpfo, mm: remov=
e
>> dependency on CONFIG_PAGE_EXTENSION") to a one-liner "return
>> PageXpfoUnmapped(page);". xpfo_is_unmapped() can be eliminated entirel=
y
>> by adding an else clause to the following code added by that patch:
>=20
> The point I'm making it that just about every PageHighMem() check
> before code that does a kmap* later needs to account for xpfo as well.
>=20
> So instead of opencoding the above, be that using xpfo_page_is_unmapped=

> or PageXpfoUnmapped, we really need one self-describing helper that
> checks if a page is unmapped for any reason and needs a kmap to access
> it.
>=20

Understood. XpfoUnmapped is a the state for a page when it is a free
page. When this page is allocated to userspace and userspace passes this
page back to kernel in a syscall, kernel will always go through kmap to
map it temporarily any way. When the page is freed back to the kernel,
its mapping in physmap is restored. If the free page is allocated to
kernel, its physmap entry is preserved. So I am inclined to say a page
being XpfoUnmapped should not affect need or lack of need for kmap
elsewhere. Does that make sense?

Thanks,
Khalid

