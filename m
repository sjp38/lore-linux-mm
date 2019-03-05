Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0128C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:35:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DD8B20675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:35:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LnEEbcFm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DD8B20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C7378E0003; Tue,  5 Mar 2019 16:35:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2771C8E0001; Tue,  5 Mar 2019 16:35:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1405A8E0003; Tue,  5 Mar 2019 16:35:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id DACAD8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 16:35:50 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id g6so14960380ywa.13
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 13:35:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dd0IhN9cI+1i2Tp8erb3U8cREidlOlbPPgACu+UVMlU=;
        b=aA9FieA6Zf8Yzg8+WfysCC/dJdc6Ftd5012rmjdDwIy+JOJslMZgyr51vcZKjW8Hs5
         rwkTlmNUUXr8azezai/yAdLIsuGP4JcVbw5cpwPuouiG8nvDEePz8fERErjBU4KgXCl4
         u9ENCCx17/3yt65LsaQ6fbqZ7Sv50ph/y0YPbWX3QTTdebYtFUKR78fd1hlKqOYn5qvd
         he/8UihjkS9u+Z4EV46qTy87NeoM6GhCJBWdge/QLECuUB+M62pn2S/mRhjYRuKfJPuj
         5i++cbOORXugRw5E9gXc7ZfkduuiOwcxAU4vu+qIhb3HMbhZFXTSZpmu1Rco/is/WS08
         Iqtw==
X-Gm-Message-State: APjAAAUWved7QrxxWvcDz+V3MIp3zsz7vW1BDWrwj9BEGR78LjMR1Uqe
	6sKx/GU3sCU+bVIVx6Op/uAKGyesz7RJS9BdMKqo2HgsN6vYvUjYKZG7LetU0dKsp6QQcukeri1
	Nuke9M76Y0zHcbZZrK8OK4hktt/qt4FcTzLk8CNw21fC9hMBYkqBh7ga+DUFx8glRcw==
X-Received: by 2002:a81:98d3:: with SMTP id p202mr2821808ywg.49.1551821750652;
        Tue, 05 Mar 2019 13:35:50 -0800 (PST)
X-Google-Smtp-Source: APXvYqyLGndsqVIbrjhBRewRe76hEJW3uFEFS9h5b/+rFbSEH2Btl3Ab07ZU86dyx1B+92Km4COa
X-Received: by 2002:a81:98d3:: with SMTP id p202mr2821771ywg.49.1551821749919;
        Tue, 05 Mar 2019 13:35:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551821749; cv=none;
        d=google.com; s=arc-20160816;
        b=D/eXdcD/WOs4mcfhhWk9nQWfUQSNsH8ChDe0t7ufHicdEvML7v2j6fg81tL7agP+hx
         atlPTjiGvOKIy94XtlmG/a3V5TffQEV/m5va7ejUvFOOxENekulTm/OK6sGXNmX4f4/b
         dXKUSPXIOzjDX3uR0WgJwlNmj6hypmE7njcJI/6T0IpaCn5OnMG5l4UBOGRlfXCzZVFS
         HiInxE6NxMyju5cIxGvWmawg4/JCpXiMvZzZjy6Vt3wfN6vS92sb75QTth2nleDD1hYa
         nGQSdlH/saWKJvYr+n6MY90J1ZXFOj7/b7pepX+u7A4RFW+sfNWDxbdw2+wzKdnqJgT0
         K/LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=dd0IhN9cI+1i2Tp8erb3U8cREidlOlbPPgACu+UVMlU=;
        b=PrhEl9Vj21xJQUbXYX7RZkw2jOV7BMlBpefs0jEoPhzbSJj83mPZtA2mC7omks7CBG
         Vcb/lukefM3gzg8YHfZs1Hf9z4XZvLY4b4CcxuQRi+kZ3aqhWi09ki1IOZM0lTAsSQyn
         euytcr+QkJGgFmbr+351yPD3RueUWtBa5W9KfORMMzNijBsHo/z935Pw+Smnz+y5X7CE
         XuEvhEW/UQA3ddRRoRDdXmq/mWs8HXlLkGnw1qJ72MOIMMP26/lmEyjx/i1/JHYuoWpy
         C0mJQll5aA4xkK44rZbmotPU5+gt3CG+mbzbnq1gyxH9j3UQIkBcXiVTSWoKhD431HMj
         S6XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LnEEbcFm;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x14si5579554ybl.188.2019.03.05.13.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 13:35:49 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LnEEbcFm;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x25LTUQt021430;
	Tue, 5 Mar 2019 21:35:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=dd0IhN9cI+1i2Tp8erb3U8cREidlOlbPPgACu+UVMlU=;
 b=LnEEbcFmRjn9Eyva4qBxkxP6nVJGbhJ0Iezd7O7yPYHdt9hb/SUawSbfgF5t9ZT/ka7l
 mL2Xt3qRR1DYoW5TU5Zaiq0y3q5s2H3CNsnUOc12umVam0eXHSwuGTdZO2G3Ke9+ROnx
 GoZUxdYDWergnvUuC1BFy23Ioo2TUBfodfM/zqLPI1ygJ4BgGRGsSRTrNRsYGtQLl5P+
 VTsEIs3L7BVwQYGOgbBjTnIjrbsckh343xgtvuKiJnVfoVEJLk/vq0bIny6a4sTAlx2Q
 F/ZtBwmYDef8x6/JBaOAE+tDSwBPq+/5jwMZ/keGXV+Tv0OZrVfYJeIRKIILXKKNfjEh 5g== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2qyh8u87vt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 05 Mar 2019 21:35:36 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x25LZZlc012622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 5 Mar 2019 21:35:35 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x25LZYg9015103;
	Tue, 5 Mar 2019 21:35:34 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 05 Mar 2019 13:35:34 -0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Oscar Salvador <osalvador@suse.de>,
        David Rientjes <rientjes@google.com>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "hughd@google.com"
 <hughd@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        linux-kernel@vger.kernel.org, Alexandre Ghiti <alex@ghiti.fr>
References: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
 <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
 <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
 <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
 <20190305000402.GA4698@hori.linux.bs1.fc.nec.co.jp>
 <8f3aede3-c07e-ac15-1577-7667e5b70d2f@oracle.com>
 <20190305131643.94aa32165fecdb53a1109028@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9a23edc9-b2e5-839e-30d6-0723cb98246d@oracle.com>
Date: Tue, 5 Mar 2019 13:35:32 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190305131643.94aa32165fecdb53a1109028@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9186 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903050138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 1:16 PM, Andrew Morton wrote:
> On Mon, 4 Mar 2019 20:15:40 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> Andrew, this is on top of Alexandre Ghiti's "hugetlb: allow to free gigantic
>> pages regardless of the configuration" patch.  Both patches modify
>> __nr_hugepages_store_common().  Alex's patch is going to change slightly
>> in this area.
> 
> OK, thanks, I missed that.  Are the changes significant?
> 

No, changes should be minor.  IIRC, just checking for a condition in an
error path.

-- 
Mike Kravetz

