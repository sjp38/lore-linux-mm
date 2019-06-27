Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0891C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:09:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A7782064A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:09:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mxwGBgo6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A7782064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3871A6B0006; Thu, 27 Jun 2019 14:09:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337DA8E0003; Thu, 27 Jun 2019 14:09:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 226978E0002; Thu, 27 Jun 2019 14:09:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEB3A6B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:09:30 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id k10so1020609vso.5
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:09:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=t/rruMnao2wR61MPFoLKt9zfyEZplrn1UsBge3sXHjc=;
        b=Q78d5GNqDjM/xrWBo/KBFJ7gnjaQYCz/fCD7YyPufUoB5KXXQbsp3zL6l1GCMi4nsp
         ccDVHABBzA4aE0syBkMo/vZSQSLVChbIFdu3ccf5JLTHCVMgxA4xIfdydtpPV+OuHq71
         SxrITVq39wbzS/6596nBHtC19iI/opyfBt6QmwdLMP1tIux1sqkniRapDprslEukbtoi
         b4wSk/3KvLXTf1f1F6PFgT6ekJ3L0Rdh8ggXcdTRmWc9Lg0rXSutquM4ZEAKXfVVdESH
         9TRCzbJTVxQQPy2DG1ykmgOC37/eI19Pn+3Fom7flY3xwBLV+dfAeWn9PySbmcm5Ge7t
         HlWw==
X-Gm-Message-State: APjAAAUrifUffyTWjFQAxVhXtAQXJ2aw7qA5cMCOjuxqXRuz+ihQ6X+K
	hXcvpGPYe2s0DMO/XkzRGarKEJ7t87Fk1xeMJOdJn3HiOhtPwydx+kMCsVNF3RmswAeLvcWEATc
	+uC66/K4bteNZxxepfdFGWZp3R5QEUl/uYUF8iN9HGQ/UY9bRcmKfoqnXuKFAqavJFw==
X-Received: by 2002:ab0:67d6:: with SMTP id w22mr3396668uar.68.1561658970681;
        Thu, 27 Jun 2019 11:09:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcCtbD1s0UTnd6ALIT/GL6Ia+bfRM69JcLIBtmqOh/RSM/icGEY0/uK77XVnwtXynW0tZ0
X-Received: by 2002:ab0:67d6:: with SMTP id w22mr3396630uar.68.1561658969919;
        Thu, 27 Jun 2019 11:09:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561658969; cv=none;
        d=google.com; s=arc-20160816;
        b=b0DMOCbYkh0ljxsMwtKRYpB6e5ZBu6IH7I/Ik88Fe66qx+oxJzj1PHYVZl5F/Elltl
         glvbGgO5f1C9xnZWr55st4m89+S5qKlEzDCVSO+Fyv/Nl0V9SCPxXA+S4wRhw6Bd0Psi
         IuvqTra0ERYllMOFLW39DEuedPXD5lrrWEDMjXfhC2qduoMLS4gqOqRzMGxZkR1J+tRJ
         ULrQJibV06KBpcw3lCsbnaL6FSLSh2cdiyiAWunF6cGb/kFZaBjHeTWa3TRuIKf2N+S2
         X1MPnXfgNTP8H2mXgFVriOU3GthmNy+/LTY31zi8X9F4Q4SXCSe4sSyn/bmfNKd4xU80
         eKLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=t/rruMnao2wR61MPFoLKt9zfyEZplrn1UsBge3sXHjc=;
        b=JPRWwJ9Z2t/SFc8PPckB1krDRz7wBReOcTauS72yHLrwkVPC1bW79vg4H1TNX6gcB4
         5NZlEFQOTZ7AcmtssdcOQxWcU0XBHJcPmeZqW9/o5TS4BEiew+yd/RgAeBm5DnrhL26g
         SoyAq7m9rFWSQi2ISZYZ0UVERSJ3CO3YLz2Ze6Ps354UF4WYEOovkhQjQYc9VW3INXBy
         iwa1xaopsjgXlB8h6EfJ4kZfIf8NnAlOB/8heoljhKbQuHUfG8JlRrK34z+wBdEXJwCA
         x0qt/vu88DC81NZOd/dyq++v1VmAV5uhScq/OGC+Jj5PRjWNZfRKAMMqjhVr0RwwC/Ov
         uEBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mxwGBgo6;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 127si213483vsl.207.2019.06.27.11.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 11:09:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mxwGBgo6;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5RI9MIv127411;
	Thu, 27 Jun 2019 18:09:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=t/rruMnao2wR61MPFoLKt9zfyEZplrn1UsBge3sXHjc=;
 b=mxwGBgo6P/4M62KLP3A86hDTWZOF/CX7Ejy3CZTQKmD3ZyCo2ckpBT7qYCR4SAK7PHaq
 TtDTW6VWyO5sg1ciq25hYpWjWOQkJguDjbFkDiE9OJuJjniigy0p6vgSgcm6+1co8iJ3
 CRxjIi8xmNL/Ekzf98KaYOJLr/QI7o3pw4fJObUYVIBM5pqV2lY2eUX4KdfRpuETcpVo
 VvxoJlKqqWOU+Mg7tjZ4x1e010nheAklNM/3LNwGnzlkuJ7ryGhw0PxupqlcoFVmrgbS
 pDahFNsaHcZW3RzFinHP0R6ihqR+jfb1zdO5IkyCUPOrjSx/1Q1nvLAZi2dFu31GKXXa 3Q== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2t9c9q1tfd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 27 Jun 2019 18:09:21 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5RI876F020980;
	Thu, 27 Jun 2019 18:09:21 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t9acddck4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 27 Jun 2019 18:09:21 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5RI9HMH015017;
	Thu, 27 Jun 2019 18:09:19 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 27 Jun 2019 11:09:17 -0700
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
From: Mike Kravetz <mike.kravetz@oracle.com>
To: Qian Cai <cai@lca.pw>, Will Deacon <will@kernel.org>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
        Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
References: <1560461641.5154.19.camel@lca.pw>
 <20190614102017.GC10659@fuggles.cambridge.arm.com>
 <1560514539.5154.20.camel@lca.pw>
 <054b6532-a867-ec7c-0a72-6a58d4b2723e@arm.com>
 <EC704BC3-62FF-4DCE-8127-40279ED50D65@lca.pw>
 <20190624093507.6m2quduiacuot3ne@willie-the-truck>
 <1561381129.5154.55.camel@lca.pw> <1561411839.5154.60.camel@lca.pw>
 <ed517a19-7804-c679-da94-279565001ca1@oracle.com>
Message-ID: <15651f16-8d30-412f-8064-41ff03f3f47d@oracle.com>
Date: Thu, 27 Jun 2019 11:09:16 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <ed517a19-7804-c679-da94-279565001ca1@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9301 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906270208
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9301 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906270208
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/24/19 2:53 PM, Mike Kravetz wrote:
> On 6/24/19 2:30 PM, Qian Cai wrote:
>> So the problem is that ipcget_public() has held the semaphore "ids->rwsem" for
>> too long seems unnecessarily and then goes to sleep sometimes due to direct
>> reclaim (other times LTP hugemmap05 [1] has hugetlb_file_setup() returns
>> -ENOMEM),
> 
> Thanks for looking into this!  I noticed that recent kernels could take a
> VERY long time trying to do high order allocations.  In my case it was trying
> to do dynamic hugetlb page allocations as well [1].  But, IMO this is more
> of a general direct reclaim/compation issue than something hugetlb specific.
> 

<snip>

>> Ideally, it seems only ipc_findkey() and newseg() in this path needs to hold the
>> semaphore to protect concurrency access, so it could just be converted to a
>> spinlock instead.
> 
> I do not have enough experience with this ipc code to comment on your proposed
> change.  But, I will look into it.
> 
> [1] https://lkml.org/lkml/2019/4/23/2

I only took a quick look at the ipc code, but there does not appear to be
a quick/easy change to make.  The issue is that shared memory creation could
take a long time.  With issue [1] above unresolved, creation of hugetlb backed
shared memory segments could take a VERY long time.

I do not believe the test failure is arm specific.  Most likely, it is just
because testing was done on a system with memory size to trigger this issue?

My plan is to focus on [1].  When that is resolved, this issue should go away.
-- 
Mike Kravetz

