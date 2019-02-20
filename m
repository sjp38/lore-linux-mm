Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A9E6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 03:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C70E72146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 03:18:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Tyn7BiG8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C70E72146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489468E0003; Tue, 19 Feb 2019 22:18:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4371A8E0002; Tue, 19 Feb 2019 22:18:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 325B98E0003; Tue, 19 Feb 2019 22:18:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5028E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 22:18:15 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id i65so8419788ite.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 19:18:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=32bcuaoahH33j0wWVyMCNI5ixNjBiXmnOLsdDYTzfyo=;
        b=Yip/TOIgs8KtcmCpZuAQN6ASCJQR1IkFmNsSn64E29WlYNgr/ysX6vPtZr85BXKrEd
         QiFq7qr/3JayXdRbeHb8rTJi0hoHCt+lVbTMZBGsljgmCbFzDJoseW6aIUQCvL5YcY0U
         a4RPtkITRWVQeo+rL6/KAX/VAWzLqd9L5HdQg0koBWVv0tUemsP6hB1SgrhCvdhZ+WIU
         ZPG0x7FxTDDts/V6cBsxjyuuE01O9vavSq1gSUSn3E9QR4k9vhmOBYxQAlQ9smYa1dhI
         9U76N0XaCSqtD8Y77r2ig/BudkpMqdsyVNSKJKYd475JHFzv8fdQGQUg6sskZ+0RiItP
         cdEg==
X-Gm-Message-State: AHQUAuae7ZaXIvZI1lJYXfGuoCqay46YQjXEyS3fHoLfjLAdT1X/zNGr
	UEc9sUU3puophmWFsTtwlclLllxvn5D5DTy3NUHI0354Bna5lPqKO9dG3p9gGnbHtUctZq2V99o
	BFy8n1DDEiWQ077vYD9z40LucNPY7fLXvTUJM436VmGnFmSJynzI3BBMmLj/ZIKVwyQ==
X-Received: by 2002:a02:4f05:: with SMTP id c5mr17847824jab.27.1550632694723;
        Tue, 19 Feb 2019 19:18:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4z+zDSixOFfmVH5bqD8kE1NMZf/ZSueBdYuotDb69rqRhic8o+VzDeTvHplXln7jAdTVZ
X-Received: by 2002:a02:4f05:: with SMTP id c5mr17847804jab.27.1550632693741;
        Tue, 19 Feb 2019 19:18:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550632693; cv=none;
        d=google.com; s=arc-20160816;
        b=yw9QI/yjgl4xwMJCUtFebAj7jms8vKZ3W2toYqHrW9HZHLcrEj5A9e8Vpuq5Ovo8I0
         CE9qSAWDjxls9FAU1ozTqbIUG0Uths5q3uPjgzVth8+LptK+oe1KshUcY0ry0vjcu3BL
         Jufm6Dl+BF53V9C02uwZOFyBY13tBZ9KchDvx1Ne0ijoUT2tp+QajIUMw0nTM7DOybrF
         SK9ToGpYPIqOWD78fRX8WXHNaOY5uDrWjYfkfnPTK26uzZciNxBnRhvqukeIBcTQFopL
         mkpCYJ/tbaOCHQbFM0iGLDc8Cliyybn04a2u0g1p0IkALxNl9+yTuSXDNvw1+MxZ2VcD
         QQug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=32bcuaoahH33j0wWVyMCNI5ixNjBiXmnOLsdDYTzfyo=;
        b=TFk/NgpKfo4XEg4mIcAHFJ6VgXn9qGG/9e2gdPtSgxlLcqEelS4LTEsZka+9/EGPHk
         wXzo9j/RUZGdoGh7do0chfp8/CrgHSdKCYLezdB4KWXUP93M9fmBpwCOlP3gPVOUjYjh
         qP+gLf+gga3RSDgweJYgZERzqP2E8GqDLI5nCGnlVpiJsF7OfeogTo0rVbKjD6saKm2i
         RcwV6zrX02dfMuu/Pxdqu1FgJB7UrEXeqZJLkN69923FZLjV35TT7vWeHemEyMUIAu/o
         0G/Z/XMWFq0xk5mGujf6uGPd/6RchE5VGNmcVIlW07LIdljXUPiSSsZLWzqb5hN/qVWI
         kSkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Tyn7BiG8;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u137si2494144itb.128.2019.02.19.19.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 19:18:13 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Tyn7BiG8;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1K34U6n011239;
	Wed, 20 Feb 2019 03:18:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=32bcuaoahH33j0wWVyMCNI5ixNjBiXmnOLsdDYTzfyo=;
 b=Tyn7BiG8/A40YcwI4i8IRdUH+1PXf22ovxARqulC0VqgxjPjT7z/NtpL0uM25bJ5obwm
 tHwPAwGUQ0DmO/p7IVR1ErgfvNiE8QEpcnYeGYfGXVq8Hx71kaxmaU0xa6e1gR0swk/8
 kibezuxv09Fv8wfsD+5ZR4ng+dVig5dU+W2BhWEaFnwgdJYwBevFVGqEO6PgKibQfTd5
 n94tHTvem3TYdz3Ct3utU728FXuwREk4OD1oMtA0prGTfJz3484S9WoHGQfTVbYGJMk1
 sdUZsf1XB6NHYzhQy7zClgsAcnErDQSRQv0iYFZGwMX/sPjhDDFByYe6pS4ioBkS6YAD bg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qp81e75cy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 03:18:10 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1K3I8iv016532
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 03:18:08 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1K3I79I023976;
	Wed, 20 Feb 2019 03:18:07 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 19 Feb 2019 19:18:07 -0800
Subject: Re: [RFC PATCH 00/31] Generating physically contiguous memory after
 page allocation
To: Zi Yan <ziy@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Michal Hocko <mhocko@kernel.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Mel Gorman <mgorman@techsingularity.net>,
        John Hubbard
 <jhubbard@nvidia.com>,
        Mark Hairgrove <mhairgrove@nvidia.com>,
        Nitin Gupta <nigupta@nvidia.com>, David Nellans <dnellans@nvidia.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <f4cf53a3-359b-8c66-ed15-112b3cf0f475@oracle.com>
 <FDDDB4C8-C5B5-46B0-9682-33AC063F7A46@nvidia.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5395a183-063f-d409-b957-51a8d02854b2@oracle.com>
Date: Tue, 19 Feb 2019 19:18:05 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <FDDDB4C8-C5B5-46B0-9682-33AC063F7A46@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200019
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/19/19 6:33 PM, Zi Yan wrote:
> On 19 Feb 2019, at 17:42, Mike Kravetz wrote:
> 
>> On 2/15/19 2:08 PM, Zi Yan wrote:
>>
>> Thanks for working on this issue!
>>
>> I have not yet had a chance to take a look at the code.  However, I do have
>> some general questions/comments on the approach.
> 
> Thanks for replying. The code is very intrusive and has a lot of hacks, so it is
> OK for us to discuss the general idea first. :)
> 
> 
>>> Patch structure
>>> ----
>>>
>>> The patchset I developed to generate physically contiguous memory/arbitrary
>>> sized pages merely moves pages around. There are three components in this
>>> patchset:
>>>
>>> 1) a new page migration mechanism, called exchange pages, that exchanges the
>>> content of two in-use pages instead of performing two back-to-back page
>>> migration. It saves on overheads and avoids page reclaim and memory compaction
>>> in the page allocation path, although it is not strictly required if enough
>>> free memory is available in the system.
>>>
>>> 2) a new mechanism that utilizes both page migration and exchange pages to
>>> produce physically contiguous memory/arbitrary sized pages without allocating
>>> any new pages, unlike what khugepaged does. It works on per-VMA basis, creating
>>> physically contiguous memory out of each VMA, which is virtually contiguous.
>>> A simple range tree is used to ensure no two VMAs are overlapping with each
>>> other in the physical address space.
>>
>> This appears to be a new approach to generating contiguous areas.  Previous
>> attempts had relied on finding a contiguous area that can then be used for
>> various purposes including user mappings.  Here, you take an existing mapping
>> and make it contiguous.  [RFC PATCH 04/31] mm: add mem_defrag functionality
>> talks about creating a (VPN, PFN) anchor pair for each vma and then using
>> this pair as the base for creating a contiguous area.
>>
>> I'm curious, how 'fixed' is the anchor?  As you know, there could be a
>> non-movable page in the PFN range.  As a result, you will not be able to
>> create a contiguous area starting at that PFN.  In such a case, do we try
>> another PFN?  I know this could result in much page shuffling.  I'm just
>> trying to figure out how we satisfy a user who really wants a contiguous
>> area.  Is there some method to keep trying?
> 
> Good question. The anchor is determined on a per-VMA basis, which can be changed
> easily,
> but in this patchiest, I used a very simple strategy — making all VMAs not
> overlapping
> in the physical address space to get maximum overall contiguity and not changing
> anchors
> even if non-moveable pages are encountered when generating physically contiguous
> pages.
> 
> Basically, first VMA1 in the virtual address space has its anchor as
> (VMA1_start_VPN, ZONE_start_PFN),
> second VMA1 has its anchor as (VMA2_start_VPN, ZONE_start_PFN + VMA1_size), and
> so on.
> This makes all VMA not overlapping in physical address space during contiguous
> memory
> generation. When there is a non-moveable page, the anchor will not be changed,
> because
> no matter whether we assign a new anchor or not, the contiguous pages stops at
> the non-moveable page. If we are trying to get a new anchor, more effort is
> needed to
> avoid overlapping new anchor with existing contiguous pages. Any overlapping will
> nullify the existing contiguous pages.
> 
> To satisfy a user who wants a contiguous area with N pages, the minimal distance
> between
> any two non-moveable pages should be bigger than N pages in the system memory.
> Otherwise,
> nothing would work. If there is such an area (PFN1, PFN1+N) in the physical
> address space,
> you can set the anchor to (VPN_USER, PFN1) and use exchange_pages() to generate
> a contiguous
> area with N pages. Instead, alloc_contig_pages(PFN1, PFN1+N, …) could also work,
> but
> only at page allocation time. It also requires the system has N free pages when
> alloc_contig_pages() are migrating the pages in (PFN1, PFN1+N) away, or you need
> to swap
> pages to make the space.
> 
> Let me know if this makes sense to you.
> 

Yes, that is how I expected the implementation would work.  Thank you.

Another high level question.  One of the benefits of this approach is
that exchanging pages does not require N free pages as you describe
above.  This assumes that the vma which we are trying to make contiguous
is already populated.  If it is not populated, then you also need to
have N free pages.  Correct?  If this is true, then is the expected use
case to first populate a vma, and then try to make contiguous?  I would
assume that if it is not populated and a request to make contiguous is
given, we should try to allocate/populate the vma with contiguous pages
at that time?
-- 
Mike Kravetz

