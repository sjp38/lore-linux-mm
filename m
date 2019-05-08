Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0DCEC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:16:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59B3020989
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:16:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="y/TCL95R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59B3020989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA92F6B0003; Wed,  8 May 2019 16:16:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E58CD6B0005; Wed,  8 May 2019 16:16:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D20AC6B0007; Wed,  8 May 2019 16:16:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3E7D6B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:16:31 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id d12so88462itl.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:16:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RNyiBPHYmMKPy9Ae5WLvwYN+r0cY1awKN5dSIQUf1PM=;
        b=l2R48Rli3NiVGL2CI0Gr+xeh3bWIPaO7OMGsGsWU9OfTegfqHwEHzwOOrypw63kS2u
         tj6l0p4z2YBH96p34kcgqEcLwk6ycz6bkjbX4wSUP5gQyHrHOQ4f7YM3lZiGPN0nEsX7
         6VRK4vmONs9e+KmHTFFedZPm02UlWH6LhQu4waEOaAa4YgrFX12cwdn6mKPUn8SIb59S
         osvFnN0PYWXGgYSebUWTnQo10OEefuIg8woT+MMKz6wExbUUNDChO+eo9ZHIL8lJc+O9
         tpU5yWQ53qx8lGI1lAiSmWuz3D5Or7c0+HvUA5IEC492JRzj/TLWW/uma9INjkxarDiF
         Uriw==
X-Gm-Message-State: APjAAAWBdpiFe7H1ZzDFy4q1TgvFiydLsJJc8GyT8WLbp2bnmWrsZh6P
	U8jGI3728hC2xlGkpQZ2Haf6dXQySHiRfTjgExoFnzuQyss8sppmiYuV/H8fLaxrgES7j4CluKS
	D+/B6qSt7mXFKud0kRSfBYUq1dIaSMKS2XKb8gsrF17R+3QT3+tId9TunDjcSK3U0CA==
X-Received: by 2002:a24:478a:: with SMTP id t132mr5024917itb.123.1557346591380;
        Wed, 08 May 2019 13:16:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywoQnjJAg+IJsdFC0bnKQsA8MobXFQcp1nynkyKgqhxXhEOYKnlkUro4V+uQZi9OiMuqCO
X-Received: by 2002:a24:478a:: with SMTP id t132mr5024872itb.123.1557346590480;
        Wed, 08 May 2019 13:16:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557346590; cv=none;
        d=google.com; s=arc-20160816;
        b=nfVcPXM3kf9JjDZMqm2TneiAlp7bjY24MXNKOWJiViWgyeUE2zYRspbQLQzQJKwUf0
         DLRkg0nNtcgP/AwgZ338ohkAoCdSiw/ZwzxGwKf4P4kAFoFpqAT5JxoeZFV6GDNjqh/f
         I3/wzgw3qnPZq3g3GN9IKMi72GZ5QauZtxP5p9pF45aLZrQJe6rWVOukHG0yOd8dOCKh
         zoWiX1z5uF9RAq+erwa4mBrTi/OyEARH/btobj8orAXDPIawt9sMUlgQVCTJ/V7G4a7r
         c6hsXHFYeRloH8oWzdTX2mraLTQ+Hx8A3wKbjfgsdKUB1UBO5HP5HPcoT5HHfNeCn94H
         SRvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=RNyiBPHYmMKPy9Ae5WLvwYN+r0cY1awKN5dSIQUf1PM=;
        b=ZtAydNAEP5DBbaI0kHdqjUSVNrCk32Gazu8YIIa+7elIF1bESXDnFdXfHksafKj0jG
         7Q2UthqLK9oiJevUrwt2si1/OSnlaSFeQANDGXT8RpTzWDEBIRUT2L96nMgDGmL1QbcC
         0gRvmzQdJctQRwjZFG0Epv9bV6wpOqRjAS25EcdPjAHzu1dpKsPBnLQhPE+bw8UrP4+b
         Mwd4HRvMg8bJ4aPAirdJ2Bg5hUg8DlSOeiOrZ6pmipya4UsXFq4mr1CLC4KAnK7wU8W8
         xz6R8pgvuDTVZPYwXVBBZ1aNW8OipY2gmEYbGG8mlpSF/kQ0LexeQSKt0sfuWs9jX0Uy
         OuLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="y/TCL95R";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c23si5049ioi.71.2019.05.08.13.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:16:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="y/TCL95R";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x48KE7Sw139454;
	Wed, 8 May 2019 20:16:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=RNyiBPHYmMKPy9Ae5WLvwYN+r0cY1awKN5dSIQUf1PM=;
 b=y/TCL95Rml3dD4NpWNmcSltG1tNIp46T5O+MdFYvMJD9CGl0ObYJAHZ+EBHDVsfaoLxR
 HNuv4F9EbW+pwZ3JnWtmXK1IaBTnVvo0f5bZt3PKv8mi6LnvDz073Pe4CTHHYWXXw8bG
 8GDjv8SM8UXXY8bYJmV0Rbi6m8TAXJuHgCrnieYQbYrIbfoXJLRAgEHG0Zj8XqV1UhLx
 w+Rxq6LZ6j8pQiOP8jcrMHhECLb+xBSx7hlx+ptO9ACBfbgKblb5dQAcT+TAL41qfKSl
 D5SBBKtV7/kN2aG5rRydMzzAsCsy6liumZZhjKRGvxEQmj7wASMO7K05iqKQrNLE1Tlk Aw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2s94b66prj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 08 May 2019 20:16:21 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x48KF9SY093762;
	Wed, 8 May 2019 20:16:20 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2s94bac3s1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 08 May 2019 20:16:20 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x48KGIXK020586;
	Wed, 8 May 2019 20:16:18 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 08 May 2019 13:16:17 -0700
Subject: Re: [PATCH] hugetlbfs: always use address space in inode for resv_map
 pointer
To: yuyufen <yuyufen@huawei.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org
References: <20190416065058.GB11561@dhcp22.suse.cz>
 <20190419204435.16984-1-mike.kravetz@oracle.com>
 <fafe9985-7db1-b65c-523d-875ab4b3b3b8@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5d7dc0d5-7cd3-eb95-a1e7-9c68fe393647@oracle.com>
Date: Wed, 8 May 2019 13:16:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <fafe9985-7db1-b65c-523d-875ab4b3b3b8@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9251 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=976
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905080124
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9251 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905080124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/8/19 12:10 AM, yuyufen wrote:
> On 2019/4/20 4:44, Mike Kravetz wrote:
>> Continuing discussion about commit 58b6e5e8f1ad ("hugetlbfs: fix memory
>> leak for resv_map") brought up the issue that inode->i_mapping may not
>> point to the address space embedded within the inode at inode eviction
>> time.  The hugetlbfs truncate routine handles this by explicitly using
>> inode->i_data.  However, code cleaning up the resv_map will still use
>> the address space pointed to by inode->i_mapping.  Luckily, private_data
>> is NULL for address spaces in all such cases today but, there is no
>> guarantee this will continue.
>>
>> Change all hugetlbfs code getting a resv_map pointer to explicitly get
>> it from the address space embedded within the inode.  In addition, add
>> more comments in the code to indicate why this is being done.
>>
>> Reported-by: Yufen Yu <yuyufen@huawei.com>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
...
> 
> Dose this patch have been applied?

Andrew has pulled it into his tree.  However, I do not believe there has
been an ACK or Review, so am not sure of the exact status.

> I think it is better to add fixes label, like:
> Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> 
> Since the commit 58b6e5e8f1a has been merged to stable, this patch also be needed.
> https://www.spinics.net/lists/stable/msg298740.html

It must have been the AI that decided 58b6e5e8f1a needed to go to stable.
Even though this technically does not fix 58b6e5e8f1a, I'm OK with adding
the Fixes: to force this to go to the same stable trees.

-- 
Mike Kravetz

