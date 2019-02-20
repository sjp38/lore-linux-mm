Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E09CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 01:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C1412086D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 01:42:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IHdcvjdI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C1412086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98BED8E0004; Tue, 19 Feb 2019 20:42:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93A788E0002; Tue, 19 Feb 2019 20:42:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828A88E0004; Tue, 19 Feb 2019 20:42:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3988E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:42:22 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 142so8093471itx.0
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 17:42:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0kOON4EnOwgFd0nBOr2SneFrcTGpZMhp+rI8Q4PUR0o=;
        b=qs5m+nR6ryeUKa6y+cQThBdq7QdhzUdj3vv+CP1IpHfdRp77zeMnE2+PJdRz9y6DTv
         TqwW31IrnB5HG5RnGwAq2sbEilShlGFi93ZEsWk9jg5uG8iCWFmL7IUSlNjFV+75lcYN
         cHgFEgFhym+5WxZ6GeXAT9iDfyDkH3u8EGJBktQv6iIjlUBxqNlgj3kST+NiDZLDPoqL
         gOlm3n4fL6Eu6J4jHBRAQWtFWp4i7zIwmSXQVmdKwrPXBhqznUEnVJIR+lVN4vCYX3T1
         40ct21pZLlxZd0KMYt6KvPxEraU8wmVqqLipIf7bqI+VUO/+zzPAeHy5s88bnVxhAn3g
         hf2w==
X-Gm-Message-State: AHQUAuZ5GY4E647V7OsvWGYKWjiJRJaWL34xXAcZQw6GosgNr5DhAO6d
	kHL6JWiaRq0NjGLDR9yksQwQf+YUKRX/96/oUHRZS9Vb9KUqYJnJBNRwCwb2FKAPcpWhi/uJ4Qs
	n7l5hvK2ptwxqRAp4RtaXmots+suOD028S/oCATA35aar+dSkaxYeEjMQrephAMXUMA==
X-Received: by 2002:a6b:8d81:: with SMTP id p123mr18651366iod.104.1550626942105;
        Tue, 19 Feb 2019 17:42:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+gtzHElSBwWnufOw0e7AJop2hpwDhIgmPeRxGjKRLHj9Bld06LZC6nOGsjaqjlTAVTr8m
X-Received: by 2002:a6b:8d81:: with SMTP id p123mr18651341iod.104.1550626940906;
        Tue, 19 Feb 2019 17:42:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550626940; cv=none;
        d=google.com; s=arc-20160816;
        b=XLJPnmQuEvBTML1aCi9igRel0zkCbe2AjnCQKu8SlD59CAfKDLb2C8Ndt34DIM8Ouc
         LcIKu9koCYPbmk1m4nIet0PzgK2d4KljaHpGnrCSJzo2Xjq0kNI3Yb/Z+kXDuNc2ivYE
         SuKpdVjIvipTSsSxlIZCmETUF9jq0t7nIClFJ9tdaphAgiAaMZhLp5QbnLtAB6nAsjbO
         Qjf9huoobwR20ZFtImJW2GxWCbRWBUyWIhhhQoXvlFX2+78uCJ78v5/eEhHME/jG3y7j
         ALeNTzGzqMXKqACdGIfHUV0SAACc//lEBoh83luPrgE14aIyOt4E/fIVEoDsIJYezPvv
         WG2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0kOON4EnOwgFd0nBOr2SneFrcTGpZMhp+rI8Q4PUR0o=;
        b=W6LtPPaycJk0jX+iNbxPneK57dLvF3ksmwmcbCea+tCJ0HZhdbjz3yp4u2WiR5TzaJ
         QZ9o5LyOEq3t9ZxOXJR4gA4x20lkp+q8uDpliKq/dOCM9TNi1sJpcDD1MnU0oEYy67+k
         gDswv73is6KnjQF88O0NMa3mIyLdUeEwEbWViJ/xWoWgL2QtRhNGkAZK94a2TgubfD70
         EOQFCKqfufqOw98DfsC+En4sU/GHnhA1NvqImoQ24Ivm6iQtUmXPwdqBzD5waoexZmVg
         SK3pzc4oYL25o7BOqNIru4DF0FEAwBbfHRBtGtWUIXPiI2wVGbP0KNKAYCPGjM9ko6Qf
         MUQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IHdcvjdI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b15si2232251itl.134.2019.02.19.17.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 17:42:20 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=IHdcvjdI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1K1Xjau141214;
	Wed, 20 Feb 2019 01:42:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=0kOON4EnOwgFd0nBOr2SneFrcTGpZMhp+rI8Q4PUR0o=;
 b=IHdcvjdI/ehzMXEfZavx9gwhNkuvl87I9k2GIL7JVPUw4UMeP0D/AyAkQJJhwraNHCyz
 boUUKk8D/XCcGCq8ndBPQEIECblP5NXR1+R3HC24CdoxzECIXYle66gpRY6UGcCSgg4U
 epd+T7deoS2iuqItmstTRakjmU55CyzqNR96oh2JVX3WeCkE6PjFn4doCrMn72hjI4AH
 LLTpRJ1H2jxTYcVIF6Cd9Ki9rS9POxgOpdkZFRIMqZEo5ddDKHQfkXBgLEbDV9NwdT5P
 yrGSEyCIdz3O4BWdUFPDKVBAr0GQcHTkNIeLagmX0MheHacCc+ZqWHliIt1Slwimx5ME xw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qp9xtxs80-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 01:42:17 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1K1gG0u027959
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Feb 2019 01:42:16 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1K1gFvl024234;
	Wed, 20 Feb 2019 01:42:16 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 19 Feb 2019 17:42:15 -0800
Subject: Re: [RFC PATCH 00/31] Generating physically contiguous memory after
 page allocation
To: ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
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
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f4cf53a3-359b-8c66-ed15-112b3cf0f475@oracle.com>
Date: Tue, 19 Feb 2019 17:42:14 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=917 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200009
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 2:08 PM, Zi Yan wrote:

Thanks for working on this issue!

I have not yet had a chance to take a look at the code.  However, I do have
some general questions/comments on the approach.

> Patch structure 
> ---- 
> 
> The patchset I developed to generate physically contiguous memory/arbitrary
> sized pages merely moves pages around. There are three components in this
> patchset:
> 
> 1) a new page migration mechanism, called exchange pages, that exchanges the
> content of two in-use pages instead of performing two back-to-back page
> migration. It saves on overheads and avoids page reclaim and memory compaction
> in the page allocation path, although it is not strictly required if enough
> free memory is available in the system.
> 
> 2) a new mechanism that utilizes both page migration and exchange pages to
> produce physically contiguous memory/arbitrary sized pages without allocating
> any new pages, unlike what khugepaged does. It works on per-VMA basis, creating
> physically contiguous memory out of each VMA, which is virtually contiguous.
> A simple range tree is used to ensure no two VMAs are overlapping with each
> other in the physical address space.

This appears to be a new approach to generating contiguous areas.  Previous
attempts had relied on finding a contiguous area that can then be used for
various purposes including user mappings.  Here, you take an existing mapping
and make it contiguous.  [RFC PATCH 04/31] mm: add mem_defrag functionality
talks about creating a (VPN, PFN) anchor pair for each vma and then using
this pair as the base for creating a contiguous area.

I'm curious, how 'fixed' is the anchor?  As you know, there could be a
non-movable page in the PFN range.  As a result, you will not be able to
create a contiguous area starting at that PFN.  In such a case, do we try
another PFN?  I know this could result in much page shuffling.  I'm just
trying to figure out how we satisfy a user who really wants a contiguous
area.  Is there some method to keep trying?

My apologies if this is addressed in the code.  This was just one of the
first thoughts that came to mine when giving the series a quick look.
-- 
Mike Kravetz

