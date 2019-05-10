Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80CF7C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 22:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30349217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 22:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tJDg3KFb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30349217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B22376B0003; Fri, 10 May 2019 18:45:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD1096B0005; Fri, 10 May 2019 18:45:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E8396B0006; Fri, 10 May 2019 18:45:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66EBE6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 18:45:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s5so4928372pgv.21
        for <linux-mm@kvack.org>; Fri, 10 May 2019 15:45:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=bf8P4q788pObPSRhE2yikT3tYYSQpmCfY0xoTw+mRbc=;
        b=bQsCZOrecQWKOTUx+cEvahsgw1psMNwKuQrPmms14o7WkViFg2FjLy9BgXTH5eeGgr
         +umA8TniJaMwYIXpIOa724QclRQ0k7FZeG1bob7nAzOwYB6A1+kkF6GbZLu6Y+iLMdzx
         EGrXbl4dHXjHxwUTBjfn1ROG1+fj+6UWpN4r1e6UUQSvVUER9P5ZtwePKomJdlLKMGBU
         g6hrCI3PWjJqhjC4PrEqAb2baqzsAYtmrFmhCGZLl4KTyO0OMGJ73JvlMzcUcEnFw0qr
         eN/2AZaVq89lr06lXd0Ujg/qtwsJVMhMyx0e6j4JbdEwmHaVJYWRpo4FO8mIKwtmTyTf
         SyWQ==
X-Gm-Message-State: APjAAAUcnz6Di2PppwfPI5tgR6DfEOSSuD9Bm3i3rjohwErJBTzQfiy/
	/u6huy7CCqSH3gAg17EF6FliEXKx1njhONmJYtB0g8QxP8+aVxkx/4bTYDwOCG+gTf6fKv7g9nh
	yDknHTF4GUbDLTr8lWxCpZmQnLkuOSj3SMCfvZCHTTZ/6j3wg84FEG7sq5FWIm8zrNw==
X-Received: by 2002:a17:902:5a07:: with SMTP id q7mr16171817pli.287.1557528331064;
        Fri, 10 May 2019 15:45:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiYuHfaRtVDpKtnlgXFGXyqo80fU4JVa9qOLtcj+wZbTYyE6Glpg9DPx6uZF9oC8gRtztT
X-Received: by 2002:a17:902:5a07:: with SMTP id q7mr16171770pli.287.1557528330341;
        Fri, 10 May 2019 15:45:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557528330; cv=none;
        d=google.com; s=arc-20160816;
        b=xj8fJLyB2TafC5J220rnAozyzFzE53VxxA8wBp8ihc1QAqGXDOHSSQyG7SdiAqWfFW
         6aS8oUoYqJUGm0IjRWyqOs5jEWxFQx699TRVmnMIb58tvCJgSlK/JnVS4YAt6nBXYyD5
         tgejJ7yJ3aP6yuEXJqkuA4LsDctkdis/2tP50iVrtCPDTtgT227GAdSfPGsmgyTwrq2y
         YfrarS1H5ukhmmTFtEMgCMn95xNaki9lMIhJitbzfvKL/hUfBHqextSTgt4umIpInl4L
         HcHQpyHlcVUOSX3iy6ItZHujMOuS0J2UtcEf1K1fEqCpw0v2t3/zoYSM26xeldlg4owL
         m3Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=bf8P4q788pObPSRhE2yikT3tYYSQpmCfY0xoTw+mRbc=;
        b=Qkf2WVSOBN8ydFDwe19o3TPh8+nEeivQ4MBYshj/cKcnHyR9GrwiaTBBDcrN8ttcvZ
         Tr8NzmIKYGsIQRQunS0uW768CVM30XNHh+Lq2LipL2KjDEKs/OmkJ65s6HDBE9O/5Nhj
         gg6QKWQ8mSei9781E3FU826nGFJz/Max0xgmv19ZGg1aLLLRRhrj4Cpf/+DVKkNb0qD4
         uOHo0qgEt6prF8U9Ps65SQpu/viPk379fo0qJXpnC5ucS3v7pIR0/B8bwATQMPkGnQD7
         PSPlOEOk2DwGV5HvFNQSQVlH1TPIcEyoYzOfh+HCQYDNoCDQBhjxSerbcDFtSl9xAqPb
         RcMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tJDg3KFb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b89si8472977plb.351.2019.05.10.15.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 15:45:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tJDg3KFb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AMiYvu139156;
	Fri, 10 May 2019 22:45:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=bf8P4q788pObPSRhE2yikT3tYYSQpmCfY0xoTw+mRbc=;
 b=tJDg3KFbDYIWEVqN4zRx/qTj/SM3kNWXyLq8DekKk43DPTy4EJHOJoil4dQOslSkD0Fq
 8iunHzoBxOxSlelf6JLFmdzQj8nXkCwduTFP+mohuZ+4V+/7WVXDuCxhJrPY1cft9uTr
 VA5djX2Z2BfHHiFh2M0+dgE6PGwYX3rNP04HmZlOrNHmOWNZXxfBJumAOJDD5eVF04g6
 XPVd8mPBJD+Ad9RnRpO5yydcWexPYUKDqDWwZvF7uDkbGFCegZTnQpN+9FxA5Ch0syFd
 ikPpnIjYazDAUp4v/QAMiW7CUYHo9JQkntMVr4FFPQkiTysvRcYATetsKTdoJc9xBSWY Xg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2s94bgkuj5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 22:45:12 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4AMhSbp190646;
	Fri, 10 May 2019 22:45:12 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2s94ahm8f7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 22:45:11 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4AMj5kX031257;
	Fri, 10 May 2019 22:45:05 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 15:45:05 -0700
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
To: Larry Bassel <larry.bassel@oracle.com>,
        Matthew Wilcox <willy@infradead.org>
Cc: dan.j.williams@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nvdimm@lists.01.org
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
 <20190509164914.GA3862@bombadil.infradead.org>
 <20190510161607.GB27674@ubuette>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <af218b46-ece3-1189-e43c-209ec5cf1022@oracle.com>
Date: Fri, 10 May 2019 15:45:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190510161607.GB27674@ubuette>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9253 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905100144
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9253 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100144
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/10/19 9:16 AM, Larry Bassel wrote:
> On 09 May 19 09:49, Matthew Wilcox wrote:
>> On Thu, May 09, 2019 at 09:05:33AM -0700, Larry Bassel wrote:
>>> This is based on (but somewhat different from) what hugetlbfs
>>> does to share/unshare page tables.
>>
>> Wow, that worked out far more cleanly than I was expecting to see.
> 
> Yes, I was pleasantly surprised. As I've mentioned already, I 
> think this is at least partially due to the nature of DAX.

I have not looked in detail to make sure this is indeed all the places you
need to hook and special case for sharing/unsharing.  Since this scheme is
somewhat like that used for hugetlb, I just wanted to point out some nasty
bugs related to hugetlb PMD sharing that were fixed last year.

5e41540c8a0f hugetlbfs: fix kernel BUG at fs/hugetlbfs/inode.c:444!
dff11abe280b hugetlb: take PMD sharing into account when flushing tlb/caches
017b1660df89 mm: migration: fix migration of huge PMD shared pages

The common issue in these is that when unmapping a page with a shared PMD
mapping you need to flush the entire shared range and not just the unmapped
page.  The above changes were hugetlb specific.  I do not know if any of
this applies in the case of DAX.
-- 
Mike Kravetz

