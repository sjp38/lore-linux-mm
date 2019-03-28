Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 804F9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3012C20823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="G09CZy9Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3012C20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D03276B0280; Thu, 28 Mar 2019 16:44:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8B536B0282; Thu, 28 Mar 2019 16:44:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B054E6B0283; Thu, 28 Mar 2019 16:44:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72B7A6B0280
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:44:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r13so34046pga.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:44:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=J/Sv2txgzYEAQ4VYGS+H5dOrwerREpOEMC59LuErUdk=;
        b=fee3siMPUiqgxH3CjRTQ7hhCGuq7Ku8u1T8MhBhrtyGdNrh44rPXHBwLfA9Yyq/TVR
         +/eTsE+XNI0RVtRC0gAHHdP/jN9GaWPqkC5zg5P+7vQXgTvZCqEG25y8IdceSsREFwNK
         FM5FQsui8O1PpXSafIPJeH/gQ0dRQDa6L9oW2QG196QXw3F6eiwghp82+CABCLTttYO+
         6m2fkDcv20dEYVbufYw4HOdleaKvTifa3VEQCnfXLoovcuqoad3pbYGnTk5tI/WRO97l
         IWnDAngKxK/Qym4tzJ0R7yiy0zO9XxqpzTAtHkAAtKrtwiyO8npPR6Xt6wIdcf2Yb5D5
         +eVQ==
X-Gm-Message-State: APjAAAU23a/PEK+xq1cHPjW4DdiHfjXzS2Tw40KZnamw1ukDQFaiGvS7
	Zp3PhzbZTYscCmqmNtMIyRbO/CHrnXITcGTqk+P1HEp/9SrrQJFIJhliC1GVcwpxDeK8NxnB6W7
	AYPFdkpHUEXE9IMVWAu/RA8hXA6fcugSWxWww/u+TNG/ep0mqrsjR3GgZE0/m30cbXw==
X-Received: by 2002:a17:902:2e03:: with SMTP id q3mr44235625plb.166.1553805866146;
        Thu, 28 Mar 2019 13:44:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUwtiTAuCLxVnUPNL4voUocfeGyfXuOceZw4v1pCbGrwaueSJ36YPZt27sQ5eIqLzNTO44
X-Received: by 2002:a17:902:2e03:: with SMTP id q3mr44235583plb.166.1553805865335;
        Thu, 28 Mar 2019 13:44:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553805865; cv=none;
        d=google.com; s=arc-20160816;
        b=HD8dZpcp9YNtnuJT4RL13OyIYCTEKD9NunWJ/JT7bJVj+MerhoO+OYLg841rse9oT/
         ILMtaVQRULNwPjxM1usK5dZS+nMFmJUf4rL7dChXQE9OslBF9R3pAcW53viqST8XHE1o
         PoWJcxxgwhehseQ7J5D+oQn0j54104OsJf97V6tH/N6ZClx7wteo2ErscgZh9Fc0BvnY
         PN7sWE+12K46IlWKGZBybM05r9Y/OsS2fgkSIrV9WtM6+U+Vou/sb3YjjKTX7pt2CAre
         qOLngphOx79jCUqMOX8EvbFk3OzZ86ANkq/SMVX8aKddnmJRWrgdtY+EV0QXjprx9q6C
         TUGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=J/Sv2txgzYEAQ4VYGS+H5dOrwerREpOEMC59LuErUdk=;
        b=AOzzU2nvPsSOH1pc/zR8DSDwNWQ0fe7iIs8NMMbN+6uAYmv4+sDlh+lTwH0+qx2luG
         TK4NlgEdOw/JD1C8Sm+V5jEIbQ7S3pBDjynJh7MgPGpnvlDimQAzfoX3fHcQIHLHcvhF
         ulivXacm/be8SW6yoZ5ji6hMalWPoZYjjjWB6snUExLMeHAhIPaMOto4ylBMbUazNdv6
         PBXsTHN8MdMGZi5SQ6OuCJjCbwVbjKdHj1y8snp2ulukhJ+DAXSKBSMrk5Hrm4QZwP/X
         QKxJyYjtoQZzrT3qfrXJ4aHsWuMvBweVcXwmLcKGqCWhV+VnuMJHC3Ml7VeWZrVYwRtV
         6dRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=G09CZy9Z;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g10si87930plb.375.2019.03.28.13.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 13:44:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=G09CZy9Z;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SKcwSi194673;
	Thu, 28 Mar 2019 20:43:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=J/Sv2txgzYEAQ4VYGS+H5dOrwerREpOEMC59LuErUdk=;
 b=G09CZy9Z0roM3J+ekA923y0scmmhw58c0EyD8iu6QUJEMHCuxhJios+WlIW3SW5iL73B
 13/C8qhnL08l/kO+BTG55KGvtEJ0sDQa1ef6mKANMn4jHKqih0MsrBQL4H5OOLOn2x/s
 XlzIHjdvMTtmI23IFkM90a4QdtkyikJLP7vIIxbLAH+GZj1QXD4mOz9yCjSrc+oNlPOf
 UqRC53OnOd9RdKE7AD92McPwrIwNQJQ1ibaAFZ8Xa3otnpP3Dxrcuw7purThc4o06ASu
 iRfG+TdvKA5K/JeEiHpcLKS0YRHGAKbT01uzeNa2/Du0jOzIo4YdHGf2YcycVJIz5iPk JA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2re6djs2kv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 20:43:47 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SKhiLW020325
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 20:43:44 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2SKhOq4024431;
	Thu, 28 Mar 2019 20:43:25 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 13:43:24 -0700
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, aneesh.kumar@linux.ibm.com,
        mpe@ellerman.id.au, Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c6a93f46-4d8a-e7fd-3f39-4c3c5a9ed514@oracle.com>
Date: Thu, 28 Mar 2019 13:43:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190327063626.18421-5-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/26/19 11:36 PM, Alexandre Ghiti wrote:
> On systems without CONTIG_ALLOC activated but that support gigantic pages,
> boottime reserved gigantic pages can not be freed at all. This patch
> simply enables the possibility to hand back those pages to memory
> allocator.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: David S. Miller <davem@davemloft.net> [sparc]

Thanks for all the updates

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

