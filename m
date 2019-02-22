Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3677C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 02:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EF4D20818
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 02:44:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dAslaHW4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EF4D20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF6F28E00E6; Thu, 21 Feb 2019 21:44:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA6E88E00E2; Thu, 21 Feb 2019 21:44:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6F808E00E6; Thu, 21 Feb 2019 21:44:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADBC08E00E2
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 21:44:30 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id j10so549134ybh.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:44:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:to:from:subject:message-id:date:user-agent
         :mime-version:content-language:content-transfer-encoding
         :dkim-signature;
        bh=OF/rgCGfOorrF8sNMcynyWe4p0PqDyp+ekmtZGbzME4=;
        b=M+SHN/vTh9ZEHtFiLzhAA1PmAdoKWMX5Mkp+50gejgqEUDwgj+eXdvta7xN5PBVLvT
         6XHL3+lMkpAbE8yeZLNYiVn+4lQq9q0WiDfDYuX3jU7y9wGliTEThYR5m5qFnFIBXBzR
         4AxRcsEZMm8GoVftUsCi6GJuhntifOwP4748FQ+V2OcMdDfcK0m6SwC73PNs4luqjh4Q
         bf/qOXNOMChQ/69+mTowM9dQbSTejDG7yBgL2NSMSGo7lHdx/t5oLKxWpQmWaqzXava/
         sTdwaIkQGqaOPKq4rQhjraimgIdPtiAxbnYM1A5Dc1Yve+poS+ctqfmxMeuCVxh/FLgq
         V34A==
X-Gm-Message-State: AHQUAubFSZmn73BExVSi0rBuTem2CAVPZpvoWZtolLZrwfl/3q5Rt76R
	Q1DYdcWIsvzi0VuALDmvBBwvjCu3aDmyY4sSy5dJ7rwKWVvczBgZVduMj+8oju+GMLY4Gv1E5hG
	y/BteZ7o8RrVvKajAUP0vtSk8GVKKaRsKXt1yKbIq+44VMtyqbm2OSkGWOSh6qi/0lQ==
X-Received: by 2002:a0d:e193:: with SMTP id k141mr1523140ywe.166.1550803470252;
        Thu, 21 Feb 2019 18:44:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYV06P4NJ1ihV8uxqSsAiSmPPPH2JhxSNNqO5I2Zlq0yo+IeDGHf3oI64PBE2coHkvi5IyQ
X-Received: by 2002:a0d:e193:: with SMTP id k141mr1523096ywe.166.1550803469275;
        Thu, 21 Feb 2019 18:44:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550803469; cv=none;
        d=google.com; s=arc-20160816;
        b=BsgkeJk1NhIj1qTW92V4BOy1XVD3hdcNx7H462wpTX+uCfzc0uJ6bxgpAmSE9LRuI3
         3tqWcMy4nIAj+NHnTev2gEqfm8hZAFbrhOMdWxubWr8EUjDtd6jiGmb8OGTEc0OF0WNa
         Cfv4+j3gTHYf7zeFA9Ba6PTtc6rK6jA/aMqHe15WBYSh7C3EnL8CuU3cTUbqv1erVGwK
         uQWEPY2EsELgLOkPPGTb4KRJjPK8fKR5MG7RCnv2I626/gE/zaRlEYC5WjdplqbWUcaf
         EKaNgvp4v84E5Gr96r0RxKbxpPaEFuPKQYEMceOSka1PlyoC2+uQbU8W1nzJpQzbv/TL
         hxJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :mime-version:user-agent:date:message-id:subject:from:to;
        bh=OF/rgCGfOorrF8sNMcynyWe4p0PqDyp+ekmtZGbzME4=;
        b=DE83wwJXRLk4JPbJPQTv0yuT9xeoDMckN5e2lOVLznkQVr2/ez4opgqIkMKO/qwd1R
         m4A4XdKHtAWvQGdGzrEZafAMwrMy5uzMy0xEnWEzLCZABXsf4vOn9XgNS+9moaz1+OMh
         YEZJRCylJ3Wbz01Kw8k9Dlft9VwH3PmmjmTogX7onH2vH8KXe8Y1PIAtMrHW5akNoP2h
         fgrgHoXwwtlcz2m9uCPPIgrlgfERPQ8ZjEQERYMpgOA6i+WG54f4yrSz7z3sPIRTM1/h
         sX1gEWygrD2NDQkxI8U/cUpQo9Nk8+O5VRDJwE9r1xNysnQ8jszPKCf/GcLSAKhesfKd
         EUbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dAslaHW4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z5si121282ybc.157.2019.02.21.18.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 18:44:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dAslaHW4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6f62120000>; Thu, 21 Feb 2019 18:44:34 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 21 Feb 2019 18:44:28 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 21 Feb 2019 18:44:28 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 02:44:27 +0000
To: lsf-pc <lsf-pc@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
From: John Hubbard <jhubbard@nvidia.com>
Subject: [LSF/MM ATTEND] gup/dma, file-backed memory, and THP
Message-ID: <213b47b1-a63e-06d6-e3ae-fa16e5a23a69@nvidia.com>
Date: Thu, 21 Feb 2019 18:44:27 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550803474; bh=OF/rgCGfOorrF8sNMcynyWe4p0PqDyp+ekmtZGbzME4=;
	h=X-PGP-Universal:To:From:Subject:Message-ID:Date:User-Agent:
	 MIME-Version:X-Originating-IP:X-ClientProxiedBy:Content-Type:
	 Content-Language:Content-Transfer-Encoding;
	b=dAslaHW4eMIKJl4iRzbaNbhTrrRVw4HWU8yEk2wghS4s3oTRxPkDwqTyq0nf8LgMr
	 d9uVwTP5M1HkgTS9wNyB4kB11czJARFNJjcSij2CpkvjY2BqKQwQhPkFbcQP+HFfXm
	 cMo3jREP5i72gmDL0tqJ8f2+CHznok91cIc/OshjSDSE6qi0dy+6mlSL3wXTuFNCad
	 NYlAOBKoveYt2qjPsuS0kLq3lr+6j9cGkziaI1/K9AU9+tWqK7OKUW8zfKcB039Dx0
	 nQFYJAz7eDpIlqM0s4MpY/XVdOL+HuopTMIPGjCTN2uXUpL4NMQePY+MdcICuuWS53
	 kTyEB6TTlCx8Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'd like to attend LSF/MM, in particular the following topics and areas:

-- The get_user_pages()+DMA problem. Here, the page tracking technique
seems fairly well settled. I've posted an RFC for the page tracking [1], 
and also posted the first two put_user_pages() patches as non-RFC [2].

However, the interactions with filesystems are still under active 
discussion. That is, what to do when clear_page_dirty_for_io() lands 
on a page that has an active get_user_pages() caller: this is still
being discussed.

I think there are viable solutions and we're getting there, and I
*really* hope we might actually converge on an approach at this 
conference. Although, it's very awkward that Dave Chinner can't make it!

-- Amir Goldstein proposed a "Sharing file backed pages" TOPIC, and 
this is very closely related to the gup/dma issues above, so I want
to be there for that. And generally, get_user_pages and file system
interactions are of course thing I want to be involved in lately.

This next one was partially covered in Zi Yan's ATTEND request. But 
his focus was slightly different, so I wanted to come at it from a
slightly different perspective, which is:

-- THP and huge pages in general. It turns out that some high-thread-count
devices (GPUs, of course, but also various AI chips and FPGA solutions)
do much, much better with 2MB pages. In fact, it's so important that
we've been expecting to be forced to use hugetlbfs, in order to be
guaranteed those size pages. However, it would be better if the system
could instead, reliably and efficiently provide huge pages, to the point
that a GPU-like device could more or less always get a 2 MB page when 
it needs it.

Also, perhaps a minor point: there don't seem to be kernel-side allocators
for huge pages, but in order for device drivers to use them, it seems like 
that would be required.

[1] https://lore.kernel.org/r/20190204052135.25784-1-jhubbard@nvidia.com

[2] https://lore.kernel.org/r/20190208075649.3025-1-jhubbard@nvidia.com

thanks,
-- 
John Hubbard
NVIDIA

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

