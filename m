Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E958DC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:11:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A68DE2080A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 19:11:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="LzzXd638"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A68DE2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 465728E0058; Mon,  4 Feb 2019 14:11:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ED258E001C; Mon,  4 Feb 2019 14:11:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28DDC8E0058; Mon,  4 Feb 2019 14:11:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAA478E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 14:11:50 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id x132so57406ybx.22
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 11:11:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=WJmOpp9hjc5i9FcdMolKyZT9L4tb15BeDAuReza4xvo=;
        b=qjvWRzqLNdNlELUm/Gf5C81LIn+WTF7I9MZ65VpIix8oDkOJeQsAsllYIELxKrwdW+
         B9xcj1WNYhlTXoJbzmOrUr5odYoqUClIXSXDT4thrYxR1ADeaZTN8uc7UH7t71tlaxyh
         czIkaa/AgsJZ31t7fmh5NeTxqlg0CuBM6U9+ubnEb4nN/U5b440giyR6fyEQDRX3yE4b
         cqJ3nr0OTj/mXTveyLMwrMPP3s1do+OAu1cCk83iaK665KZ9D4G37JjKX+eVNqS5fNa5
         s64NccfmMW3TQcVDM95rFDbGVR5xr0ajDaJLLV60GaE6dXBcoG+sdxaG4IUw9KBsxQwA
         2k2A==
X-Gm-Message-State: AHQUAuboKrELyMDorQHl3DnoKi069h+fFw+5RTPPmiLoJFvFellU5bh4
	s6AoReVttCavTkTb5mM+DcSc7EBt2q0oRe0VaV0mxqHafNUX0pE7Ws5eec9uhQ8MvAvIv8oH0a0
	WrgU5NZq8KrF2TX/hoxU0wBbcg3mbAiOFEf/qLs5gWGK1ooUp+jaiJBj+J3A8HlW7kg==
X-Received: by 2002:a25:9946:: with SMTP id n6mr852983ybo.156.1549307510512;
        Mon, 04 Feb 2019 11:11:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6pMg1sQHiMtsPPMtB+1YGTYgZAUuQQvN12yb9yw6n3czNLF2HUIci/ENw1pl+mb2DJaUM
X-Received: by 2002:a25:9946:: with SMTP id n6mr852943ybo.156.1549307509803;
        Mon, 04 Feb 2019 11:11:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549307509; cv=none;
        d=google.com; s=arc-20160816;
        b=onCY7DNFm10ExoxrHqZjxp2fCb28vcFVo9/JwrYAtVjrriik1UJTHgRiumGBSY0L1g
         tuh7YXpBOd+IrHGRAMB7dViPXNOulVXhCBcN2BH0Q0Jw57WnHi9pfuhU/sSisff6uMH2
         9mjo1WuUEoFa/r4xxL9a/qOBlE5/RQdpMHT14GiukZto3v3jopPO6T1AFwCSeOdJ7V88
         AEStW6/zHt+Itz4WUCv03SM++0WzYYQHGkIKCyvK2y1O5vyr7zfO7iTLG6UKPBGRc0mg
         HISkMP6pQVo3asnjKaldDVQ/eNAvCmb58ZzB2tkwoZUz/jG1ciXzt/eKlMjpl2w7M8GI
         XqAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=WJmOpp9hjc5i9FcdMolKyZT9L4tb15BeDAuReza4xvo=;
        b=eDDa4zFKsdrmYK8mUNl7bnaXHknHp0oXtY+n8EV/ri6l6xYknXD8Kfzf50JwNdUycR
         I3n5ZxImIcs356DbjVF6aj35fAZFiSqDO5M1hD+jnQinjq4Ryn7pgprtuboCQKjkGUYM
         u8I9Y+9izAEDL1Dt+f08yPkWfhtfUphsoXUb3w0Unxco4tWGdxMemQ9E6yasFIYrP7tX
         Fl+GPZSnMFmHwvs8QL24dytNvpmts12e6qqMYdM8HruL5Y1k7vuc2B8u87DcWh8zr92N
         ltgkOSa5u7ptGC0CqffpOLwEeElacO8KhEn0Sou5D43BuO5VCUiXAzayH1CkwdqWoluW
         VJaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=LzzXd638;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 83si555014ybg.221.2019.02.04.11.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 11:11:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=LzzXd638;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c588e560000>; Mon, 04 Feb 2019 11:11:18 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 04 Feb 2019 11:11:48 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 04 Feb 2019 11:11:48 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 4 Feb
 2019 19:11:48 +0000
Subject: Re: [PATCH 4/6] mm/gup: track gup-pinned pages
To: Matthew Wilcox <willy@infradead.org>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko
	<mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <20190204052135.25784-5-jhubbard@nvidia.com>
 <20190204181944.GD21860@bombadil.infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <f99faa07-5139-602f-dac5-3f72f16632e4@nvidia.com>
Date: Mon, 4 Feb 2019 11:11:47 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190204181944.GD21860@bombadil.infradead.org>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549307478; bh=WJmOpp9hjc5i9FcdMolKyZT9L4tb15BeDAuReza4xvo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=LzzXd638u1XMmc+ElbDj1YOanoDeGKHAdwbB4+O7StuXZJE3+DtthQyzUge3Cy/1i
	 NTwlka1kfeKHNp722TaLkL/+Zgw+xv4LTc1MEZy90zZwbUHCQQRCWTRQdd47B+kRRO
	 lixXxP5Wo4PIIgxfTIb7aDkNOrSAIUCmugEwjvnIpbGj9tNOgA1v+SBBLIS16L7cQB
	 hI+V0E/XispNBrQ5DPaccPToIUpaekPPsStWy0a1WH63K6wSNw9v3wyeuxgPNOcRGH
	 6BNWkB3sZlziejAvgJoColb5Lg2au/n3e6AGqaormGN0LtHtVP+sSlp5YstQoL51+q
	 HqSFul0QqR9mg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/4/19 10:19 AM, Matthew Wilcox wrote:
> On Sun, Feb 03, 2019 at 09:21:33PM -0800, john.hubbard@gmail.com wrote:
>> +/*
>> + * GUP_PIN_COUNTING_BIAS, and the associated functions that use it, overload
>> + * the page's refcount so that two separate items are tracked: the original page
>> + * reference count, and also a new count of how many get_user_pages() calls were
>> + * made against the page. ("gup-pinned" is another term for the latter).
>> + *
>> + * With this scheme, get_user_pages() becomes special: such pages are marked
>> + * as distinct from normal pages. As such, the new put_user_page() call (and
>> + * its variants) must be used in order to release gup-pinned pages.
>> + *
>> + * Choice of value:
>> + *
>> + * By making GUP_PIN_COUNTING_BIAS a power of two, debugging of page reference
>> + * counts with respect to get_user_pages() and put_user_page() becomes simpler,
>> + * due to the fact that adding an even power of two to the page refcount has
>> + * the effect of using only the upper N bits, for the code that counts up using
>> + * the bias value. This means that the lower bits are left for the exclusive
>> + * use of the original code that increments and decrements by one (or at least,
>> + * by much smaller values than the bias value).
>> + *
>> + * Of course, once the lower bits overflow into the upper bits (and this is
>> + * OK, because subtraction recovers the original values), then visual inspection
>> + * no longer suffices to directly view the separate counts. However, for normal
>> + * applications that don't have huge page reference counts, this won't be an
>> + * issue.
>> + *
>> + * This has to work on 32-bit as well as 64-bit systems. In the more constrained
>> + * 32-bit systems, the 10 bit value of the bias value leaves 22 bits for the
>> + * upper bits. Therefore, only about 4M calls to get_user_page() may occur for
>> + * a page.
> 
> The refcount is 32-bit on both 64 and 32 bit systems.  This limit
> exists on both sizes of system.
> 

Oh right, I'll just delete that last paragraph, then. Thanks for catching that.


thanks,
-- 
John Hubbard
NVIDIA

