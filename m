Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A586C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:09:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0742A2082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:09:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kSpm6LzI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0742A2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B59B6B0273; Tue,  2 Apr 2019 16:09:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93C3A6B0274; Tue,  2 Apr 2019 16:09:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 804206B0275; Tue,  2 Apr 2019 16:09:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B78B6B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:09:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n12so6402262edo.5
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:09:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LIspMWHW71GFK+LqCTTdKuLzcNoQ6tcNFwVwOAg+GwY=;
        b=QFd2In2dr82z+iokDxFo+NrThjpxyDsUhs9yrvsnW8Yym22CN2Cl/nVkhG0geP27eV
         NR6ilmasC5dVzCO9Bo0xe2OBytoOdT35E55jtKn7cs6+qGvs6VL8jkpG6kb8nOZwprkG
         jvZCNisITwheFhrtwdyLDL9rmm4qBFfYACfNun5iv3+GPzzw1zqWGrnWlmZ/AlLrTyd3
         n3NBpLnI+5i545thnxbV2d1122fn5kgaUlL8A3917ya0Hi/m1xmS3HgB4ZK182ux9Gie
         HrktXro3/LIBTAmTU621rGAlrallm13sc3+x9q2QPPjAgZSOIJRkZczxkj65tWoL912Y
         68AQ==
X-Gm-Message-State: APjAAAU2iFJKfSVeTVgp6V8dZuNXZd98qm7gM2RulZZ4T/hC59XSCfsl
	K25kB5zBmPeR/nWQPS8baBkAvWubo1CY1eQPd5XrboEfTJs2dBz+UWk97vs1LGfIg0CVztN1Y/T
	wvAQRQnVBTAh1ngy/HhruaUzP1EBgpnSE+obHkyyXLOz5Xat0/QtHX+ApUeeWTnHazA==
X-Received: by 2002:a17:906:6acc:: with SMTP id q12mr41542034ejs.203.1554235786613;
        Tue, 02 Apr 2019 13:09:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4mfmvuMpt3vkRDmE/VyDrhc1qM4f1nnfFEykarc27Cm4A1cw+xDIKbgJpMYfqfNqsYiGB
X-Received: by 2002:a17:906:6acc:: with SMTP id q12mr41542007ejs.203.1554235785697;
        Tue, 02 Apr 2019 13:09:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554235785; cv=none;
        d=google.com; s=arc-20160816;
        b=hMiFLtbpTe7ChlH/VTXNB0eWAyjWxkqtFOQXJZj3p4cvkt2P+9kfiONhR234KYhf5g
         UEJ+o7ZGUMqUHFSsqo3VUYTZ588fdT2KS2KJbC2LqZ+JeqgDLMpnVi0czzZpTCUdHSoy
         bU8Z6IDZS6Fc6aKm+g6Cs+kW1faEC7Er+MtkrHYZkroQ0Dq7jyshWqyhRH2O2gaA8njc
         mu02ZI9geTToaRCOP1Zm7oUSaeVSaGTnd5QQVfXbHSdsoYFnB5koigqTPU5F2uIPq3Hm
         JpGOWeKvoTF3GXi6j1bHMTXZHkfn0Vtc/Q9crKlIoS9X/ShbeArXwozT7qjbYgE47whK
         34NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=LIspMWHW71GFK+LqCTTdKuLzcNoQ6tcNFwVwOAg+GwY=;
        b=EpBwEY8WDq1H2uhfJ1ObVaVIb3mMgz5m0cm3NHO9EmdvF1L63X2HJa85JhKqWYg4uW
         7FDZuAIL88RWyGmIMvdguTbnn5SmnBWoh6qtZoQuzhaL27rIMah0B51cS/6i5UZQdj3u
         Abmc6CiO9TKMAV3dsDwZLOupnLZ8ZdQrZ8vWvjw5r8mD2ag5jli/UYDBo3TnFUlNHnaF
         k9Xk1dO8GtyWzSeoI0vUht72jHCbWPHqFT+LdXG+TYVu74Bn9pPRKP7sBXmHWxl24B+H
         f7bDGvXrGRqecDfjv2Wjb1iVAPz6LSz+jzL1bmQu8DgtycHvAqI57HbpqPZx7P92UTtP
         eSvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kSpm6LzI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t13si343896ejs.392.2019.04.02.13.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:09:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kSpm6LzI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32K3qsN128422;
	Tue, 2 Apr 2019 20:09:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LIspMWHW71GFK+LqCTTdKuLzcNoQ6tcNFwVwOAg+GwY=;
 b=kSpm6LzI63RA+ddKYLtunS1jDjzDWyN9Vx499rJZkU2UEbcl7/fnNlhnnqxbQ6COh4o0
 Zc7Hfr5kMiRwazOlDJd/gGwctk6hI2xVI3IcxNuMQTURK/NYXbTs61ppH6GH55Bu6Ho+
 tw8B/i31viah7lSnOYuW2EMmMn5ukxLYEFb0jkanFGq1m6bPXR4vp9Phottgf1uiA6o6
 3u5RSns1Igs7Ldajy5ZAMtz+zKzHryiTTmQgnXDUCOpQIi8TRdlOMpEqu6bK3Kmq6udh
 /QOWvJiIhESzLUjKP3VPpFBYGNNKiDN3EBT2XRptB9avgyNqJmLVHWbIWGgjA5khpVBB ZQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2rj0dnkr3q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:09:39 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32K9dEe129209;
	Tue, 2 Apr 2019 20:09:39 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2rm8f4q5mk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:09:38 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x32K9YIT011039;
	Tue, 2 Apr 2019 20:09:35 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 13:09:34 -0700
Subject: Re: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
To: Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.de>
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190402133415.21983-1-osalvador@suse.de>
 <20190402130153.338e59c6cfda1ed3ec882517@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <360a3016-4b35-3ec6-0716-1c2a62836f0a@oracle.com>
Date: Tue, 2 Apr 2019 13:09:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402130153.338e59c6cfda1ed3ec882517@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020134
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/2/19 1:01 PM, Andrew Morton wrote:
> On Tue,  2 Apr 2019 15:34:15 +0200 Oscar Salvador <osalvador@suse.de> wrote:
> 
>> NODEMASK_ALLOC is used to allocate a nodemask bitmap, ant it does it by
>> first determining whether it should be allocated in the stack or dinamically
>> depending on NODES_SHIFT.
>> Right now, it goes the dynamic path whenever the nodemask_t is above 32
>> bytes.
>>
>> Although we could bump it to a reasonable value, the largest a nodemask_t
>> can get is 128 bytes, so since __nr_hugepages_store_common is called from
>> a rather shore stack we can just get rid of the NODEMASK_ALLOC call here.
>>
>> This reduces some code churn and complexity.
> 
> It took a bit of sleuthing to figure out that this patch applies to
> Mike's "hugetlbfs: fix potential over/underflow setting node specific
> nr_hugepages".  Should they be folded together?  I'm thinking not.

No need to fold.  They are separate issues and that over/underflow patch
may already be doing too many things.

> (Also, should "hugetlbfs: fix potential over/underflow setting node
> specific nr_hugepages" have been -stableified?  I also think not, but I
> bet it happens anyway).

I don't see a great reason for sending to stable.  IIRC, nobody actually
hit this issue: it was found through code inspection.
-- 
Mike Kravetz

