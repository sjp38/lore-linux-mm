Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8385FC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BBC221BF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:04:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="B8F2O2Vp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BBC221BF2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBE8E6B000A; Wed,  7 Aug 2019 11:04:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D701D6B000C; Wed,  7 Aug 2019 11:04:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86056B000D; Wed,  7 Aug 2019 11:04:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABEF76B000A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:04:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l9so82231179qtu.12
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:04:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=IqEIMLVV4kddVXnZJfS1xffdsUoxMj0x3RpU4RiLPu8=;
        b=mp565vwc4YeVG7wF0PRtKU295RIvdi+SxhL0LeFOpSXxbCBoZuLizVGaphnz5J/HyS
         EMatKCZq1BkiRPPLenGPVcOA/iwzVUXhthoNPee8bb+R2KRfTgcgOUbbQ7FIdXwJpruq
         ZBruZ+DyAfQ0jCgxMgUBxd4KLxWJhbVIVhODXiIWDXOm5qXyZunM7JuAfoSA83zblRAI
         taAKxlCMUyfZJHPhIbP9aQ2otNj0c3y0TAFzCWAM3IQdfDmbQxmsaXHhhALgFZ0RGmya
         nmDMtAmDIAQFMphYgv6QZcqw7C4SGrl2BzMb5ZGsyGTJUEmtZZ5Ph1cXJPXcImm9Sz2a
         T2xQ==
X-Gm-Message-State: APjAAAUIuDSUFngcJoYZiIvK3yomInt+YnzVeQ+lTdGaZpzGp5700+DJ
	2rfnwhwxrloYzAIrf01GvRLm5vByLjdtlIszOSJc9NanbUJh3zBIvP5y80K6Z5uGJ99vOkcWMDT
	om9hfGSsUsaVxpn06QS769fdfe+1UNI7M7SAwWt+i8lBMGy+LIpC/8L2Nl+xLteTJwA==
X-Received: by 2002:a0c:9687:: with SMTP id a7mr8667058qvd.163.1565190258477;
        Wed, 07 Aug 2019 08:04:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDjEQ7SKZan2ZTcD14vsmX0Dr2O88XuNfvMziJtkSiTcmEw7EMMBW1jsbmhbBKU1sQIHnn
X-Received: by 2002:a0c:9687:: with SMTP id a7mr8667006qvd.163.1565190257967;
        Wed, 07 Aug 2019 08:04:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565190257; cv=none;
        d=google.com; s=arc-20160816;
        b=th40zIp6SsWy8OG/XhrsUcqc3k99v0sWBxWMjnutqcccBPNdQkMNsi3Fpq82NHrxZV
         Mz5SEQcRB7i4zMKR0S4As4ZiEaaNj9uHETUifKefcugU0jQwqxBvx4ChOXYp6Si7ngnI
         hS8XAl5b+MLxafKPNh+8eJmhlo02kOwKYxI4XC8m0QARVwnjwJGbXdPjJNnf/mBmfOAX
         1ltVQd7Up8kcHzidAV0309to1uGaxWwcDecbmnyXVIDfHyJGqrOXclBJCemTk3H7TNyt
         v/968TbWaPXv8zdM/05GwxLlCHiZWXZsE2b/6qmDssn013l6AOyjbGR11rBIo8D3KrmG
         xyjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :date:message-id:from:references:cc:to:subject:dkim-signature;
        bh=IqEIMLVV4kddVXnZJfS1xffdsUoxMj0x3RpU4RiLPu8=;
        b=NFv5QaaLRc56xbeK4digGePV8o/nWwD4KW+e6rtZfHC3G7mS72kfaxzXxj7BoGiMTC
         XQYMBEXJsRQUWPMQelZ0SK36PiIRddICjApiMbUDvGWwunle/RQ3Z3GwFZCTIUDTamBG
         xJ8IsHJ4A5bpMg/G9oGhfOIsjZgNj3I9pzOEHV2Bzd6LY6bngf6qYptNMW6jeHSkPxye
         jJ+WBCHnFouKB6SsaZQf7+jDT/Z22aezMR9IZEo1rNiQvVvQ+0HSbY+fdQe0DQCYX3Iq
         fFZoFJkz0uHWQbauHFG8+qabC/Nf1VOkjPEtunXYgB/CNqLnPTArNl+4SRdFk8xVAjIc
         FK4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=B8F2O2Vp;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m96si24159864qte.32.2019.08.07.08.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 08:04:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=B8F2O2Vp;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77EuxLk147110;
	Wed, 7 Aug 2019 15:03:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=IqEIMLVV4kddVXnZJfS1xffdsUoxMj0x3RpU4RiLPu8=;
 b=B8F2O2Vp53mKyqG33qkN95bjU4r9/3WQ5BVDHujmrmN0ssokiEsZK0DT+k1C3VmDvZAJ
 FARDzIdpx++EwrdzN7obEkqNLTUB6lvaZCDLL4Mh2Z2z30DBKB3pHaKGnIwCzJvD1lO9
 HEruwepuq75JE2KG9OmBePKvrbsiyESBaVGhT+pTQ/P1nKk1GnVvQOjoVjIEABDybU/l
 l6FInKOpGdfUfJc3kOSlBkWio5mwJa6DB8mj4zi1BOQLI6RRTwr9urjSqy9o0qF5MzGs
 WAMoTApX4TQK3yOeSNf7KhqS2bh5JheRwH7cchHLuLBw0X/0pP4G3DMRz2VbT6PfDHLo 3A== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2u52wrcx2k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 15:03:54 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77F3Whv170036;
	Wed, 7 Aug 2019 15:03:53 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2u75bwh3ev-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 15:03:53 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x77F3qX8015964;
	Wed, 7 Aug 2019 15:03:52 GMT
Received: from [192.168.1.218] (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 07 Aug 2019 08:03:52 -0700
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
        Michal Hocko
 <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>,
        Yafang Shao <shaoyafang@didiglobal.com>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
 <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
 <20190806111459.GH2739@techsingularity.net>
 <CALOAHbCxBdGtTo9SneNtnDKWDNEZ-TcisE9OM9OagkfSuB8WTQ@mail.gmail.com>
 <20190806155904.rwd7tmbbpmif4edh@ca-dmjordan1.us.oracle.com>
 <CALOAHbBPSJx4ZmsEDt6LfbVSPW1CfYTrbQvGas_SDWVd_v0wEw@mail.gmail.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <83922dc9-c556-1aae-fd5c-6199aa60c87c@oracle.com>
Date: Wed, 7 Aug 2019 11:03:51 -0400
MIME-Version: 1.0
In-Reply-To: <CALOAHbBPSJx4ZmsEDt6LfbVSPW1CfYTrbQvGas_SDWVd_v0wEw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=829
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908070160
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=865 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908070159
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001341, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 9:03 PM, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 11:59 PM Daniel Jordan
>> Do you plan to send the second patch?  If not I think we should at least update
>> the documentation for the admittedly obscure vm.min_slab_ratio to reflect its
>> effect on node reclaim, which is currently none.
> 
> I don't have a explicit plan when to post the second patch because I'm
> not sure when it will be ready.
> If your workload depends on vm.min_slab_ratio, you could post a fix
> for it if you would like to. I will appreciate it.

We have no workloads that depend on this, so I'll leave it to you to post.

> I don't think it is a good idea to document it, because this is not a
> limitation, while it is really a issue.

Sure, if it's going to be fixed, no point in doing this.

