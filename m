Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65A9EC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:58:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 194CB21874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:58:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="O8zlqbgL";
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="wGPKK2I0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 194CB21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95A5A6B0005; Thu,  8 Aug 2019 12:58:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90A6C6B0006; Thu,  8 Aug 2019 12:58:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F8346B0007; Thu,  8 Aug 2019 12:58:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 646EE6B0005
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:58:00 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so83093706qkd.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:58:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CFZgNss8wrgVTqi9Pxil6jlXsp9W+Mh4dSklyqN+PqM=;
        b=kZYptVEwBoJv+Fx14b3hvVLpphCzH3/GU5LJZmeLspfaqc0M/J7K2cFU5M8foe4izv
         9q6NOqfmZZYzFVuL8bV0gtIVoo54FOEUHOd3FlC1K1I+THYtURpOxsHtFbNrfW9d6VrY
         IJ6e6wv9mrB1NwxGOpyFJkLwQaIIVcwdPMgEJ+NnQhQfb8mhIgV4m3gRZXEvH44XvNB9
         yTSdSETRi0QefYpfu5FnkUY5Iy3Ra6pN7cHdjp7xLAQ1+cHVzEeiuyhIB9SJlXuix6JG
         Xyb0GGZLjbwUcKPpFPvdMo2sefFJqTwjTDcX6bkPtArMl/uGW3X1vhNL/vX+2XJASqAx
         gFog==
X-Gm-Message-State: APjAAAV+fXFb/BaAOjbsOi9hUgFMwynCwaeXQ6+HJDnChPr9eXx8Ol7R
	95XaD3CoCZTRD9XK9QlOQJAySDdLzBWr24MJQ1EBr9XFFrHTFr8V6nlcb/sdE7kzMv0GoCiRhoX
	emmR88A56dahQx1n1gfLF1i0sXS/zxC4v0FDXvUBPAH7CT0BxqRWyM9IWXnrzy4TwAg==
X-Received: by 2002:ae9:dfc3:: with SMTP id t186mr7601458qkf.322.1565283480147;
        Thu, 08 Aug 2019 09:58:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysyTdMBr347vBSwG6ieLwvZPtOBKuTJkjXSjmTRlE27UJXS7MVDDNAX0ISHKsuXIjK0ggQ
X-Received: by 2002:ae9:dfc3:: with SMTP id t186mr7601417qkf.322.1565283479475;
        Thu, 08 Aug 2019 09:57:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565283479; cv=none;
        d=google.com; s=arc-20160816;
        b=0SIKxLYLFllZCxa0HFaELyHWf03zcsZJBp777SuNVw3DnIj0C7dpsWivexgBie0ErQ
         QbITRllBju9O1RxOGGkPPV9iU7dhQdS8nAiRDfawR3uhxZsWrAGEpMH4azV6bE2ZGMm0
         ylge8dwznRufxYNdHZl/KKnxXdpraDR+Dys1OElJDwgW7ndSQTGAWHkOlpjvHX1gTZnE
         ca45eGV+Na8Vdtj1C47rYWDB60pxwzdJOGbkLjkQ4OaVYsRl6k2bebzdmQ/4iHNbR7Se
         Dt1uNIyUkuqasG+tGqhDuk5PpzFAMhZpN6hJyoJXsS0BCNdVEWDfCw09Pk+fDa1vH78/
         bNjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature:dkim-signature;
        bh=CFZgNss8wrgVTqi9Pxil6jlXsp9W+Mh4dSklyqN+PqM=;
        b=08NJkGXx4RzhPByp0zKqqkXDa/7an2jZV+mWtH6wOWLj+4QZLCI8hgBLCd685zK49L
         e15p7VitfbG5qJgAx49oHd5F6EK9oqhEVOxtNBjSQQSBn7E8BU8Qi4OdzN07n6lDR7uS
         eoXpXd74eeBn6P4fpJRfs84PLmwQE+YePmo2VLwisLWusqiNGTDIS/ligcDY2zkj60/X
         Q9hrEQ9LmAZWNwpWnB4FjuJ5CJYOfLMSzOINj8oo4OIFGzuhnk2y/wOTBdXeMxcMCu1a
         VzFiRRDCdL5fqQyVxOEZhY21qsTe7BfSHDFWAHWhPeuOMmNp1a2KP6oecgdYX2Uw8YRl
         //Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=O8zlqbgL;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wGPKK2I0;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 1si58035505qvs.1.2019.08.08.09.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:57:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=O8zlqbgL;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=wGPKK2I0;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x78GftSI003876;
	Thu, 8 Aug 2019 16:57:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=CFZgNss8wrgVTqi9Pxil6jlXsp9W+Mh4dSklyqN+PqM=;
 b=O8zlqbgLE75TCxPlWeM9ocMKBlIZJG6J2V71ApEUUg6GaqdOfQVTS13GmP3rYi95oiqc
 yM3oUp0TfeyrKRo0IP2KqzIE6cMnBbduXJ0nV2KDG6PhkmlOBBkcUeAXbs6KtwplnSBY
 oWIqM/rJ85JpzmOww6CCFGAV+sRnp/0QG6pVfyqt4paiC/5cQPY8BJuCalYoc/TajzXK
 naAmpc8zat2AQObrzsQdPGPQnjdI+OEyNPhjHw/qzAf8oamanO1XAMmFHA9lNafOmJUs
 0RqQmEUQcltreVNmmT30VEAHKwBI4mOe1QgN3XDhrGfi5TPTyYrfkXSHeLPH4jMgpHUp nA== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=CFZgNss8wrgVTqi9Pxil6jlXsp9W+Mh4dSklyqN+PqM=;
 b=wGPKK2I0SarbFd2Ql9+zPXqsk+CgAFBHh6V5BwTvEQtJEgdtwl+ls2IKfgrSv2geDo5k
 ueCNmpHg6AHhmv+LjFeFNVRs36ojMc5wF4YrB8L0xeZAZS/OE4YPQ+bseE9kmJogBwSo
 Q+3nrpHUlI+h4AJFO0CP+8K9IRnGmgk4Vmyv5q1ZJywBYdylhAzxbL/X8s9uVL8Qmqd/
 hUgsw3LPn9i/pZVAoeyXI6+0b6PSgriwQbkuwIvFpYu1+wG5YfZ3eJi81oT+OyljSzge
 v/R1qa22p0QySQRA3w4u/SG7jQsuqrrNHsmDI4LH3hXEHrsGUWj4KrsTQw1pKCUOTFvu tQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2u8hgp2hep-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 08 Aug 2019 16:57:52 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x78GXLnl105386;
	Thu, 8 Aug 2019 16:55:51 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2u8pj82qfk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 08 Aug 2019 16:55:51 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x78GtlxC016879;
	Thu, 8 Aug 2019 16:55:47 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 08 Aug 2019 09:55:47 -0700
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race causing
 SIGBUS
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ltp@lists.linux.it,
        Li Wang <liwang@redhat.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
 <20190808074607.GI11812@dhcp22.suse.cz>
 <20190808074736.GJ11812@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
Date: Thu, 8 Aug 2019 09:55:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190808074736.GJ11812@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908080153
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908080153
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 12:47 AM, Michal Hocko wrote:
> On Thu 08-08-19 09:46:07, Michal Hocko wrote:
>> On Wed 07-08-19 17:05:33, Mike Kravetz wrote:
>>> Li Wang discovered that LTP/move_page12 V2 sometimes triggers SIGBUS
>>> in the kernel-v5.2.3 testing.  This is caused by a race between hugetlb
>>> page migration and page fault.
<snip>
>>> Reported-by: Li Wang <liwang@redhat.com>
>>> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>>> Tested-by: Li Wang <liwang@redhat.com>
>>
>> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Btw. is this worth marking for stable? I haven't seen it triggering
> anywhere but artificial tests. On the other hand the patch is quite
> straightforward so it shouldn't hurt in general.

I don't think this really is material for stable.  I added the tag as the
stable AI logic seems to pick up patches whether marked for stable or not.
For example, here is one I explicitly said did not need to go to stable.

https://lkml.org/lkml/2019/6/1/165

Ironic to find that commit message in a stable backport.

I'm happy to drop the Fixes tag.

Andrew, can you drop the tag?  Or would you like me to resend?
-- 
Mike Kravetz

