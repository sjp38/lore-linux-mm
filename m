Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA7ADC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 03:30:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8536213F2
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 03:30:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zPUCIEg5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8536213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44FC46B0006; Mon,  8 Apr 2019 23:30:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FF536B0008; Mon,  8 Apr 2019 23:30:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EF156B000C; Mon,  8 Apr 2019 23:30:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB9586B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 23:30:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y10so3374959pll.14
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 20:30:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=yNAnix0vPb3Rl0k78u1G6bUYV+iub+YsxxG7ebwDs7U=;
        b=Lu1ssFZAiTCxS9TRh2+RKwfv2lZkbHi96NTZrVlRWDRq3HW0hTzMK1R7r7R7PpjUst
         y6SxLCL/Sfj/T6Tl5Svmeb0IhglFkPh9uw4+WcZelzfqM8REmKwPci/D2rk7Nwg9qTIS
         FyUiVCcQFtLAX3tgw+eoQqlxJfZpsqaBY+kpwiHMpvdTCL0BIQ/hSfBf30dPj78xd823
         08e8gv7ENmMzJ/krDPu5mWlRq7ONhLGctXd2rTeGu7bOXRlRQbUuCD9WEtYEHynXYikX
         PI/GX4pe+D5QIRsavV3VZjb/Us/A/H7w32dhp89NECRncYLKnauzYha+qhZ0fQH4mMYL
         hgGQ==
X-Gm-Message-State: APjAAAXmhQ1z6OKCraLD/fcfQHjsLFHRxSvXa4oYhI46O/jBT19uwjWc
	QPqhbsWRFYtRQgVHPOk8VVdF0dEMBQ4HrRKSepqRRuJqa0n52/jxMFyvsQmJ+NA1Fj2NV021yAd
	Bscim+6tuGrDABzzMWb60g5s4DeSVzseIO72pCleaRJj/B0jipkYdgAQe/YHOF85h2g==
X-Received: by 2002:a17:902:aa87:: with SMTP id d7mr34484646plr.146.1554780624399;
        Mon, 08 Apr 2019 20:30:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0br0WCqb1gGij9IUg2OWfX9DQPcqvQZeaIL+6UBgeuRN4vtpIgDi6hMnkq63qWH2dhRNc
X-Received: by 2002:a17:902:aa87:: with SMTP id d7mr34484563plr.146.1554780623629;
        Mon, 08 Apr 2019 20:30:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554780623; cv=none;
        d=google.com; s=arc-20160816;
        b=Q1JeE2wMCqtaqz9Qfln34LQmkTZr5bI5y3x+Ns+F4YjJWW4SV6w2hxVIajNAF/7VF4
         PlJ3F2OFm8UmQ8TB3SX+AcHwuppNQeTha2McWvXPsiRLbVBxZB9WpSH4RnFB0E2lWote
         yxvME+NXSOkGnKB/q3REj+TGXTtMxXh2QRXjd/Cf/KoZ/HU2aQVVFuWR9STn+mAz8lPU
         rqLVcZCkhVTfg2qh2uvwkDJadlVb0oKAucTsPo9NfPZoPChWapRbkzjb/Vz9Cir4kNOO
         wpM3NDTtVqJQm3jSQ1PHIxdbu7MO6YbJqtJu9Zzg3ABVSZWsHHfNhTKA+RHUCAVguCgP
         KFYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=yNAnix0vPb3Rl0k78u1G6bUYV+iub+YsxxG7ebwDs7U=;
        b=f8aBhdkQnsbBixq0e70cxFAfo78MTsjRTB2FLk2JFiGvkSp+RT0BC/BNGwe52BncM8
         pyaGOxLn44d7m/DUY4Z5LFZvB4AJzYqF4kMHKniGEpMqLh90tHawIYbqi/iIQIo4BNMk
         QTUzMRbwjpBzyNxBTBbwdHw6S2EMMX+2ANG81eUdP4+DdqpT/kBlAKv0V4NaD25a91Y9
         O7VffhiCyd4wUEqkmT39kI8ZkG3Lod3GtOTCW61LTiWXexoQDDFpOn+hxhchZJm0QLF2
         7oVjIkhO3OV5TWKjgBtAmndvijlHwVAg0Garckb1K2hcli3RK2YpbPFsHbVt/XlOT3Xs
         0IvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zPUCIEg5;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f1si28072408pgm.373.2019.04.08.20.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 20:30:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zPUCIEg5;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x393T152151814;
	Tue, 9 Apr 2019 03:30:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=yNAnix0vPb3Rl0k78u1G6bUYV+iub+YsxxG7ebwDs7U=;
 b=zPUCIEg5CUbDsP0wiNhIk8OvKl7JmuJp/okBnahAcSyFxQGyUIBX0mUXXvSDwxGePx48
 NrjyTdGtU6SokLBju1C5MHRO0FJXgs6UmehpqLkJwBelmrbkxGxMum3xPyNtznCJKNyK
 tsuyXYXsx+cmTxCu9OF5v546DaJIpch/WUPBPAU0Awd6uy7o5zpfnAy6J79W1BDCI29d
 wZxF0RYoFjH9WuwuJIQcM/3JVB+lqv5g3l++SgMFyFu8b5baxaJCrool/xQ0LfBpjJc5
 bG42V9v+I+cQdSbMNEUon2THP8ovxp9E6fz/8kazU/0MNxC81zFK+2hjaBsRWs5b615w Fw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2rphmeacg6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 09 Apr 2019 03:30:19 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x393TlYX158719;
	Tue, 9 Apr 2019 03:30:18 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2rpj5aava2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 09 Apr 2019 03:30:18 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x393UFQU025909;
	Tue, 9 Apr 2019 03:30:16 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 08 Apr 2019 20:30:15 -0700
Subject: Re: [PATCH v2 0/2] A couple hugetlbfs fixes
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190328234704.27083-1-mike.kravetz@oracle.com>
 <20190408194815.77d4mftojhkrgbhv@linux-r8p5>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ec2426bc-d817-f645-b868-9edb9b4c54ca@oracle.com>
Date: Mon, 8 Apr 2019 20:30:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190408194815.77d4mftojhkrgbhv@linux-r8p5>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=923
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904090022
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=933 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904090023
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/8/19 12:48 PM, Davidlohr Bueso wrote:
> On Thu, 28 Mar 2019, Mike Kravetz wrote:
> 
>> - A BUG can be triggered (not easily) due to temporarily mapping a
>>  page before doing a COW.
> 
> But you actually _have_ seen it? Do you have the traces? I ask
> not because of the patches perse, but because it would be nice
> to have a real snipplet in the Changelog for patch 2.

Yes, I actually saw this problem.  It happened while I was debugging and
testing some patches for hugetlb migration.  The BUG I hit was in
unaccount_page_cache_page(): VM_BUG_ON_PAGE(page_mapped(page), page).

Stack trace was something like:
unaccount_page_cache_page
  __delete_from_page_cache
    delete_from_page_cache
      remove_huge_page
        remove_inode_hugepages
          hugetlbfs_punch_hole
            hugetlbfs_fallocate

When I hit that, it took me a while to figure out how it could happen.
i.e. How could a page be mapped at that point in remove_inode_hugepages?
It checks page_mapped and we are holding the fault mutex.  With some
additional debug code (strategic udelays) I could hit the issue on a
somewhat regular basis and verified another thread was in the
hugetlb_no_page/hugetlb_cow path for the same page at the same time.

Unfortunately, I did not save the traces.  I am trying to recreate now.
However, my test system was recently updated and it might take a little
time to recreate.
-- 
Mike Kravetz

