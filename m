Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13C8FC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:57:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B62FF222DE
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:57:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CdHRN3Ln"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B62FF222DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 553018E0005; Thu, 14 Feb 2019 11:57:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DAD78E0001; Thu, 14 Feb 2019 11:57:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37E328E0005; Thu, 14 Feb 2019 11:57:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E00C78E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:57:07 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so4750395pll.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:57:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=MotuX5uwsuODNodXmCNKkBCxOxRxYVbct++kioqcJCk=;
        b=QnNusQqlPs80gPEB5LU5o85bp6u4rnpJvgSPM0wBhHTprKWfHpj70eFngioa6QwuQH
         /WHNXXdtweyDZyeFPlSpRza3gku25P5fpGz/Z0t8u560H3GvPQpFx1edZUVcgA5lSvJh
         VYPU6mXLYzRo18Rsla86x6JxcjI0yqSOxJIBGgKsgyN30he0TYCrSVkz9iwd4gsINicZ
         R8keuRLsw0wlL7ne2GYNgGHL56CGpteSDG8H7GfMbg9UVAb35W9CQC1MYLQe/pLsvWar
         SPjJPwlDX53CXl93PVp1R1ZHq13t652J0zX4aYtTQQYYgjvekdpok09O8cV+2dPEj5QD
         FOYw==
X-Gm-Message-State: AHQUAuZx2QLy6UvuzJq9b1m7tSRFYe5D2aNUOymP1o6uCcBblLT8qL1q
	sV87wm87qebKGBuIHJ4L4hhfQEapg4VtJ4Oai2wNSxMvl+eZURM2ELcWdzAer+L78CUATmsxzyf
	W8toX5oth8lfPNe6F1XW2L59MtZKi8398U2X32Zkm0dq2O4eVFQbRBUw4AgjEHn9UIQ==
X-Received: by 2002:a63:4b25:: with SMTP id y37mr809012pga.181.1550163427583;
        Thu, 14 Feb 2019 08:57:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZD7Ugf/K4D2dU6+HkejDZOx5DbbF7meZLZBerACBGYIOjaVA05iL4yUP0F2zIhcSuxLUVK
X-Received: by 2002:a63:4b25:: with SMTP id y37mr808972pga.181.1550163426926;
        Thu, 14 Feb 2019 08:57:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550163426; cv=none;
        d=google.com; s=arc-20160816;
        b=MGkU2cx2Koi/SDxxeF1kPIQVgIKckqd1EnCEn2tYRJoceZXOUKofhkrMlbia8NbWOu
         /dppC2b5KPT8RVMCdHINMfiszfwTBfP9zxgxe10ZwYVWf/p3XknQEaTJ2lClRHFSA5nI
         5a5t2oi7LK8uX91VtGIu5W7jRg6KdhvRJ3Wff9A4XpvJ1E491f5bSzq+a7ww1CCKxnVm
         XKM5443gjzjdjJoom4s56BCxveIiXhCuFrocSFym4XrOkM9WLtVGOU2O9i/gV5XXZU9B
         tljaSNL8bQwN/EG61Ndg1xKD8jtLliYnlZXWsPgiOc15pPcVuiYEYLTcxp6aWzE8ojhc
         ffNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=MotuX5uwsuODNodXmCNKkBCxOxRxYVbct++kioqcJCk=;
        b=1IwcmfVI4ChfL2QbowEdj8eHMbmT5uVAXKwdIZdGoLF6Wwj/MONg2+uc9aBNu47QFf
         A505Wv3xTQ1OL0vhUBc61JwTuYFwP66LOo8Xl5V5NftbSTUZOheEn/hR9G0VN2eK1nhr
         ylx4yNEdcLS7W7ISVJyaE4YPf2xn0cRtE1QU5ZlWABnQMpAl4TvhNF4PMaUcZR7q2nlc
         KLQ3tnhlNIBPhXYzFWFdoAV1UXkGm4Nt8WdxFHy9g53gCwc0JZNPv5bVplmG8bM4FYYG
         YS/grgBU6hpIyQbCIufjmG4Cj+vVLbTraYT7Q5RdefuNEr01SQEIkVuMcv6HKxGCGCYY
         tzDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=CdHRN3Ln;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j9si2610085pgp.410.2019.02.14.08.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 08:57:06 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=CdHRN3Ln;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EGmlNw109854;
	Thu, 14 Feb 2019 16:56:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=MotuX5uwsuODNodXmCNKkBCxOxRxYVbct++kioqcJCk=;
 b=CdHRN3Lnvj3SIOrf8LqxGj+jFsmhVludo1tNIdornRvlfx3bAnQZ9mvDb7wKbaLiH28H
 8bZBksPqAZNeYfTtkQLEB2xabwSZdfl5CtlL6N7L7YLytvr16YXj/blIm9dxBriiLpmd
 Vb9IjRNLx3V45chjSmynKrhfJhI2D+DoAvYc76ROMkYkQnnbUcyielyKPkwQX8iFZI32
 s8XojcUGz2U0OQbYH0gbGl5SOdkMK7AvJI6PCdvqb9czEK7b4N5MGclhq/PtsDwjxoMx
 n2CfcCYMXOK4SCH4taB4qCaig+Tm4g2/2KHn7lQtEby4OnYscvfFAbTBsi2T4OYMIs8W ow== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2qhree9866-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 16:56:32 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1EGuUcR011678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 16:56:31 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1EGuSJX027469;
	Thu, 14 Feb 2019 16:56:28 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 08:56:27 -0800
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
        oao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        peterz@infradead.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho@docker.com>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <b595ffb3231dfef3c6b6c896a8e1cba0e838978c.1550088114.git.khalid.aziz@oracle.com>
 <20190214074747.GA10666@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <3c75c46c-2a5a-cd75-83d4-f77d96d22f7d@oracle.com>
Date: Thu, 14 Feb 2019 09:56:24 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214074747.GA10666@lst.de>
Content-Type: multipart/mixed;
 boundary="------------4E8F634EF1C80F4AD05A0F4B"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=706 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------4E8F634EF1C80F4AD05A0F4B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 2/14/19 12:47 AM, Christoph Hellwig wrote:
> On Wed, Feb 13, 2019 at 05:01:27PM -0700, Khalid Aziz wrote:
>> +++ b/kernel/dma/swiotlb.c
>> @@ -396,8 +396,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, =
phys_addr_t tlb_addr,
>>  {
>>  	unsigned long pfn =3D PFN_DOWN(orig_addr);
>>  	unsigned char *vaddr =3D phys_to_virt(tlb_addr);
>> +	struct page *page =3D pfn_to_page(pfn);
>> =20
>> -	if (PageHighMem(pfn_to_page(pfn))) {
>> +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
>=20
> I think this just wants a page_unmapped or similar helper instead of
> needing the xpfo_page_is_unmapped check.  We actually have quite
> a few similar construct in the arch dma mapping code for architectures
> that require cache flushing.

As I am not the original author of this patch, I am interpreting the
original intent. I think xpfo_page_is_unmapped() was added to account
for kernel build without CONFIG_XPFO. xpfo_page_is_unmapped() has an
alternate definition to return false if CONFIG_XPFO is not defined.
xpfo_is_unmapped() is cleaned up further in patch 11 ("xpfo, mm: remove
dependency on CONFIG_PAGE_EXTENSION") to a one-liner "return
PageXpfoUnmapped(page);". xpfo_is_unmapped() can be eliminated entirely
by adding an else clause to the following code added by that patch:

--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -398,6 +402,15 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif

+#ifdef CONFIG_XPFO
+PAGEFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTCLEARFLAG(XpfoUser, xpfo_user, PF_ANY)
+TESTSETFLAG(XpfoUser, xpfo_user, PF_ANY)
+PAGEFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTCLEARFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+TESTSETFLAG(XpfoUnmapped, xpfo_unmapped, PF_ANY)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;


Adding the following #else to above conditional:

#else
TESTPAGEFLAG_FALSE(XpfoUser)
TESTPAGEFLAG_FALSE(XpfoUnmapped)

should allow us to eliminate xpfo_is_unmapped(). Right?

Thanks,
Khalid

>=20
>> +bool xpfo_page_is_unmapped(struct page *page)
>> +{
>> +	struct xpfo *xpfo;
>> +
>> +	if (!static_branch_unlikely(&xpfo_inited))
>> +		return false;
>> +
>> +	xpfo =3D lookup_xpfo(page);
>> +	if (unlikely(!xpfo) && !xpfo->inited)
>> +		return false;
>> +
>> +	return test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
>> +}
>> +EXPORT_SYMBOL(xpfo_page_is_unmapped);
>=20
> And at least for swiotlb there is no need to export this helper,
> as it is always built in.
>=20


--------------4E8F634EF1C80F4AD05A0F4B
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------4E8F634EF1C80F4AD05A0F4B--

