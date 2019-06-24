Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25978C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:53:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0CE020665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bPIrl682"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0CE020665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 835056B0005; Mon, 24 Jun 2019 17:53:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E6238E0005; Mon, 24 Jun 2019 17:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D4148E0003; Mon, 24 Jun 2019 17:53:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2BD6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:53:15 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id n8so23661113ioo.21
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:53:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9koirtlNcPH5hLpr08phM7fwBx+iDwNGIp8nnsRtBYk=;
        b=Xw0OHxuJhmb/kNsjJnJdure1RTDsv7wPM06HsYIcpDbTDZvAUy+lQo6ZydcjtCPuoj
         BetRnSD0p2qKEr3cClXaymtZQvtjyRw7003ufu9dyqt2sCYwzen9rJER+xxMpXrk9ol6
         CVnnJl2XmAg5v48+e6OZicsPExNVFj3Hk9XLsGefvr5bPOjgbPikLb6y5KdA+DmS8rg2
         tXx1FzVGuD3jLf4HTvXf+J+90Nf1Wirxp7Yn5KV4j9EPqpCGq/GHFxVtymuX4ZCi6rY8
         4fHXy+X8GCKXM2B/iD+xPvRKbO/XFqw20FH2hRV07LBJWHO6p0P+a5VmqehRAL4aXB3q
         P5fA==
X-Gm-Message-State: APjAAAXAhY5avA6yuV4kJx0Thn+phFb5fhS1vqsi2IvFSViRCNSnFtS2
	7vgatPSdOq6EfxEUY7kh/SA/PWdpq0rjtkda4tO54XdGqEVOtIv/nNR3xyeB5RcqE6okgftlOeA
	UTHw4V69Aauq12lQ1ODDqZ7AP7IigRVhZGA97A6SOWi5xcc1RC1kQ9mVDpCrH9f/xdQ==
X-Received: by 2002:a6b:6a01:: with SMTP id x1mr34218528iog.77.1561413195032;
        Mon, 24 Jun 2019 14:53:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4587rKC+Gylquw5168dgwYSsKYG90fQWIfJPk8tjHv2AQro6ljVS/xOqAtbFpiZ4QTSzI
X-Received: by 2002:a6b:6a01:: with SMTP id x1mr34218487iog.77.1561413194348;
        Mon, 24 Jun 2019 14:53:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561413194; cv=none;
        d=google.com; s=arc-20160816;
        b=V2xTq6BfUXWbRBNNGIYQ1mOSfhWgzAxPP3xDpM0DsNUZnCWJK1RgY9cf38OrgZlRxz
         RZEznDzY7QrdJIj5FEm+z+gvWVDciIFxCP8BrMLmteYLDYpYQK8aobPu0WZgoAI7UqFU
         O3OP/HA6FE1sGPfdoue8fHT3exG5Ehng2ZhJqn+O9oUAu70Uk0MvjEA+ZDnGxTjwJW4/
         FHc/B+avN/6bsJi6KAm47oedbgziU4CjGMlKdut4x/sUeAY+h5h9Pxf8fLCF1jMX4W/d
         m9n6pfHUT/ZQF8Tq/2siCfL0Bahd5n2zE8E/RdHuQfhkjTdGtBeHosddgkzGCQY8r4gR
         MImw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9koirtlNcPH5hLpr08phM7fwBx+iDwNGIp8nnsRtBYk=;
        b=NUMAqI0qurvWavbG2hXQDb013sh4dkI60EsMHjCAo0kjGckFqFKeehoj+2anUvTcaL
         A5nmSzj2jIQ5HB623yHLWopliBN3o9SXe2g1u3h2Dy+qIemKeDwWfccIfgOuYgEEDSQG
         D8uUz7o6Sv37gbURwCP1fTiXTxJ8e/Zpu0bq420qCoHfDPyPvb0OEznEG+Oix4zy8T46
         sDzZLFpeNkEzeletHjE8kZEYSn6Wv6BB/h0x5gbbkSjMAXG8/xVl55VnF2w8Uz7OZW/P
         GrkIa4DAjnMU57wP/OWKzqbWafFz/RZd7pqhrtT27TiT/be8gePtjF4yngQXCpW9BEjM
         aJUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bPIrl682;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w1si15403393iod.25.2019.06.24.14.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 14:53:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bPIrl682;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5OLiFnJ175023;
	Mon, 24 Jun 2019 21:53:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=9koirtlNcPH5hLpr08phM7fwBx+iDwNGIp8nnsRtBYk=;
 b=bPIrl682JwIFGDstn3ppeuOpqlFXogsm/9GtggfdwsjOBCBzwJxSi8L60q5o2DgnQs03
 6dJy7dzt/CoYRT6j8XGXw/MZ96tq99abLlX1WdxfiZdPvMNKIe3DXX7d5ngoC0LGYr7+
 m/+ZQwhkKzgDJmmraYAkEyyu+HJKDWEWElcmT8ux1RHuGES8c55TRZQbyAB69JWqjQic
 ApGxQI918U/1HMrq2HJ/a3Jby++qIMPONeb4/mTqObRbhv7yh8NN1iVcGlketM/px8ar
 u3SSw/QA4qKOD07uy+pJxhod/kwk/tvmabfrzkD1BSZzC4cBBwB714PXf6sbSgNFy5Te 5w== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2t9brt0t89-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Jun 2019 21:53:05 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5OLpnZ0090513;
	Mon, 24 Jun 2019 21:53:05 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2t99f3gv6d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 24 Jun 2019 21:53:05 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5OLr3sh012267;
	Mon, 24 Jun 2019 21:53:04 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 24 Jun 2019 14:53:03 -0700
Subject: Re: LTP hugemmap05 test case failure on arm64 with linux-next
 (next-20190613)
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
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ed517a19-7804-c679-da94-279565001ca1@oracle.com>
Date: Mon, 24 Jun 2019 14:53:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1561411839.5154.60.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9298 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=7 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906240171
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9298 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=7 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906240171
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/24/19 2:30 PM, Qian Cai wrote:
> So the problem is that ipcget_public() has held the semaphore "ids->rwsem" for
> too long seems unnecessarily and then goes to sleep sometimes due to direct
> reclaim (other times LTP hugemmap05 [1] has hugetlb_file_setup() returns
> -ENOMEM),

Thanks for looking into this!  I noticed that recent kernels could take a
VERY long time trying to do high order allocations.  In my case it was trying
to do dynamic hugetlb page allocations as well [1].  But, IMO this is more
of a general direct reclaim/compation issue than something hugetlb specific.

> 
> [  788.765739][ T1315] INFO: task hugemmap05:5001 can't die for more than 122
> seconds.
> [  788.773512][ T1315] hugemmap05      R  running task    25600  5001      1
> 0x0000000d
> [  788.781348][ T1315] Call trace:
> [  788.784536][ T1315]  __switch_to+0x2e0/0x37c
> [  788.788848][ T1315]  try_to_free_pages+0x614/0x934
> [  788.793679][ T1315]  __alloc_pages_nodemask+0xe88/0x1d60
> [  788.799030][ T1315]  alloc_fresh_huge_page+0x16c/0x588
> [  788.804206][ T1315]  alloc_surplus_huge_page+0x9c/0x278
> [  788.809468][ T1315]  hugetlb_acct_memory+0x114/0x5c4
> [  788.814469][ T1315]  hugetlb_reserve_pages+0x170/0x2b0
> [  788.819662][ T1315]  hugetlb_file_setup+0x26c/0x3a8
> [  788.824600][ T1315]  newseg+0x220/0x63c
> [  788.828490][ T1315]  ipcget+0x570/0x674
> [  788.832377][ T1315]  ksys_shmget+0x90/0xc4
> [  788.836525][ T1315]  __arm64_sys_shmget+0x54/0x88
> [  788.841282][ T1315]  el0_svc_handler+0x19c/0x26c
> [  788.845952][ T1315]  el0_svc+0x8/0xc
> 
> and then all other processes are waiting on the semaphore causes lock
> contentions,

That call to hugetlb_file_setup() via ipcget certainly could take a long
time to execute.  In the default case huge pages are reserved to back the
shared memory segment.  If these pages were not prealllocated, then the
code will try to dynamically allocate the required number of huge pages.
So, even if [1] were not an issue I think a change here makes sense.

> [  788.849583][ T1315] INFO: task hugemmap05:5027 blocked for more than 122
> seconds.
> [  788.857119][ T1315]       Tainted: G        W         5.2.0-rc6-next-20190624 
> #2
> [  788.864566][ T1315] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [  788.873139][ T1315] hugemmap05      D26960  5027   5026 0x00000000
> [  788.879395][ T1315] Call trace:
> [  788.882576][ T1315]  __switch_to+0x2e0/0x37c
> [  788.886901][ T1315]  __schedule+0xb74/0xf0c
> [  788.891136][ T1315]  schedule+0x60/0x168
> [  788.895097][ T1315]  rwsem_down_write_slowpath+0x5a0/0x8c8
> [  788.900653][ T1315]  down_write+0xc0/0xc4
> [  788.904715][ T1315]  ipcget+0x74/0x674
> [  788.908516][ T1315]  ksys_shmget+0x90/0xc4
> [  788.912664][ T1315]  __arm64_sys_shmget+0x54/0x88
> [  788.917420][ T1315]  el0_svc_handler+0x19c/0x26c
> [  788.922088][ T1315]  el0_svc+0x8/0xc
> 
> Ideally, it seems only ipc_findkey() and newseg() in this path needs to hold the
> semaphore to protect concurrency access, so it could just be converted to a
> spinlock instead.

I do not have enough experience with this ipc code to comment on your proposed
change.  But, I will look into it.

[1] https://lkml.org/lkml/2019/4/23/2
-- 
Mike Kravetz

