Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 595D3C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 052F62175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:51:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mPP6alBT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 052F62175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81E478E005F; Thu,  7 Feb 2019 13:51:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CE9F8E0002; Thu,  7 Feb 2019 13:51:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E3B68E005F; Thu,  7 Feb 2019 13:51:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 486238E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 13:51:05 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id j7so525315ybj.4
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 10:51:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CY1qIemIcU7S4oq51xk5yyrbeVt0hXCjaaqLCg3A9io=;
        b=Rw8EXEsVp7LACvOLaYENFsJGpQtYKkbjGbipLawhl9gH9x5lrzlLEAQB558BnIUMWB
         QcomkWEHPsrtvbmXRLet7mi2Akef10t7Y8LNzuQQpVQdYM0RN5cmTfJh7f3XeLgg3iFv
         4jdj6RKh4Kvs4Uvp4BZAEJpolbUNFabhg64P7QGq2LfNjrNfBtAN/Hbh7uP0zDhXc3YT
         7NyIiJKIpIXEMdmkGML8w9P7un2OJ/IFmMolMYF1Idx0dpt3EcjTMk1XpQQuyVScHct1
         F0XPnaK+ELDEzfAnGxmAoHsk4OK86YmGS11LaQN2F2MXE2wG6+CUEzK2o1qHSZREq2p9
         p9WA==
X-Gm-Message-State: AHQUAubrEaosgrD6/gzFb/OnHG9t9gZfEf2aetS5PdTtvndU+VM4fGuV
	s6eiiqZoyPxKV9xMY0JgokNCSxGlRIGMn6YfM6mjFfsA0gMU/HuRpwIOB+C0HmpClQ8jInQZKjH
	vgaKhwQ0xJtO4K3K6l0nCkzhYtgjRhjish5qb92vzkCaxU02ErdPUGfW4NZ9YdnFoHw==
X-Received: by 2002:a81:3149:: with SMTP id x70mr14291616ywx.420.1549565464904;
        Thu, 07 Feb 2019 10:51:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ/8xY09P1TaFORn5Zxh2nQulvSebwnmGiK41itebJekVd82daZq8UBSwkMXwnjVx8paLyP
X-Received: by 2002:a81:3149:: with SMTP id x70mr14291568ywx.420.1549565464020;
        Thu, 07 Feb 2019 10:51:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549565464; cv=none;
        d=google.com; s=arc-20160816;
        b=Og8of6UXEN6JirRGwm1Vgvl42aJEtdyQidiQdCCMD8iSmBZm2Rzpuo1+dEuMUE/4YH
         Y6MUvW3//hPDbIR/ZMrHZUyLoOJuM80QmbHmZ7LM5PvzrX+O5qCH0aAywnkFawlj0KIp
         j2vf7ZJv8YB2Kw38rjCh8364pUi+WMbgezKofTls3oxYnedTXASr7XwtGDpYc5yw6Rvm
         /ZWt6fgdY05U9k4kZMRvriaYUsltQcQoRjz7twXPyKpOryWBb8vm9iTOy2ojdcs8R+Fs
         +2gkKTONpaGECF31pvIIA7MRjd8+9okjunvj5LFp4eOz4rJy9MVR6hjBt/vF3APCMhm6
         qICQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=CY1qIemIcU7S4oq51xk5yyrbeVt0hXCjaaqLCg3A9io=;
        b=mBGWKBU8zHunR47L0To+bFlw3FhCHc/WlpP6jG2fJspuK5e78qvk4FVN4+kVdMXJIn
         W8lIG92yOAGghmEv6I9Co2Hz/fpqQaR6c2ood3fkpItiQXv5bBmQ/1jV2xXsq8jaM14c
         uuxO5MqLFsVFMKMhfw+/Nm6gAOnMg7qdqE0Ey+HdM4rvLfurKcj8HZLbuJLOh/tPrh/Y
         B/Upz19p/uowMK/1TGt8gAQz61b/T0ATPFhv9e6eIQpoZzazKKJU1iR4M3Qg0MeoZumn
         GHZI6CfLryfakpWaA2Hw37NmIkD+amRAPbSzP0fzLddEqLfKiiNVA90V6kDWSQbBBuzx
         EbSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mPP6alBT;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c2si4723578ywe.154.2019.02.07.10.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 10:51:04 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mPP6alBT;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x17InAek026056;
	Thu, 7 Feb 2019 18:50:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=CY1qIemIcU7S4oq51xk5yyrbeVt0hXCjaaqLCg3A9io=;
 b=mPP6alBTXMCwd2BrszA7sBmzRFHYaRPYGw5M42IKT4hhPIdJe7SCqJ27GLLDjJjmZPGS
 x+BqiKSLpSgDIF3fkHykBThDcwlEe7aBM8C2eOlxAvHZzqS0pjEkoJJKmXn2q5SCnmee
 UIDI21L5mLJ+ioUmfULPaYUfS8TD5PphKzujjhOvaYFu+mmCWJOE2fyv00yUGRiu0+Bk
 C1TprmXik7XvQP+ZkCUUCj97xn6kpxASs0yjukibItTZW6GXOmoX9XypaWfvCSJKbZOe
 C/L/D3jWJyvi7KxuYGEL1dZcX9IJYLAtwSGo3yXx/laFhD7TVa7xaksUFld1mHLTpGmh yQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2130.oracle.com with ESMTP id 2qd9arrrqg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 07 Feb 2019 18:50:59 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x17IowKf014618
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 7 Feb 2019 18:50:59 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x17Iovuj023593;
	Thu, 7 Feb 2019 18:50:57 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 07 Feb 2019 18:50:56 +0000
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso
 <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
Date: Thu, 7 Feb 2019 10:50:55 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130211443.16678-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9160 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=807 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902070141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/30/19 1:14 PM, Mike Kravetz wrote:
> Files can be created and mapped in an explicitly mounted hugetlbfs
> filesystem.  If pages in such files are migrated, the filesystem
> usage will not be decremented for the associated pages.  This can
> result in mmap or page allocation failures as it appears there are
> fewer pages in the filesystem than there should be.

Does anyone have a little time to take a look at this?

While migration of hugetlb pages 'should' not be a common issue, we
have seen it happen via soft memory errors/page poisoning in production
environments.  Didn't see a leak in that case as it was with pages in a
Sys V shared mem segment.  However, our DB code is starting to make use
of files in explicitly mounted hugetlbfs filesystems.  Therefore, we are
more likely to hit this bug in the field.
-- 
Mike Kravetz

> 
> For example, a test program which hole punches, faults and migrates
> pages in such a file (1G in size) will eventually fail because it
> can not allocate a page.  Reported counts and usage at time of failure:
> 
> node0
> 537	free_hugepages
> 1024	nr_hugepages
> 0	surplus_hugepages
> node1
> 1000	free_hugepages
> 1024	nr_hugepages
> 0	surplus_hugepages
> 
> Filesystem                         Size  Used Avail Use% Mounted on
> nodev                              4.0G  4.0G     0 100% /var/opt/hugepool
> 
> Note that the filesystem shows 4G of pages used, while actual usage is
> 511 pages (just under 1G).  Failed trying to allocate page 512.
> 
> If a hugetlb page is associated with an explicitly mounted filesystem,
> this information in contained in the page_private field.  At migration
> time, this information is not preserved.  To fix, simply transfer
> page_private from old to new page at migration time if necessary. Also,
> migrate_page_states() unconditionally clears page_private and PagePrivate
> of the old page.  It is unlikely, but possible that these fields could
> be non-NULL and are needed at hugetlb free page time.  So, do not touch
> these fields for hugetlb pages.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 10 ++++++++++
>  mm/migrate.c         | 10 ++++++++--
>  2 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 32920a10100e..fb6de1db8806 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
>  	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
>  	if (rc != MIGRATEPAGE_SUCCESS)
>  		return rc;
> +
> +	/*
> +	 * page_private is subpool pointer in hugetlb pages, transfer
> +	 * if needed.
> +	 */
> +	if (page_private(page) && !page_private(newpage)) {
> +		set_page_private(newpage, page_private(page));
> +		set_page_private(page, 0);
> +	}
> +
>  	if (mode != MIGRATE_SYNC_NO_COPY)
>  		migrate_page_copy(newpage, page);
>  	else
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..0d9708803553 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -703,8 +703,14 @@ void migrate_page_states(struct page *newpage, struct page *page)
>  	 */
>  	if (PageSwapCache(page))
>  		ClearPageSwapCache(page);
> -	ClearPagePrivate(page);
> -	set_page_private(page, 0);
> +	/*
> +	 * Unlikely, but PagePrivate and page_private could potentially
> +	 * contain information needed at hugetlb free page time.
> +	 */
> +	if (!PageHuge(page)) {
> +		ClearPagePrivate(page);
> +		set_page_private(page, 0);
> +	}
>  
>  	/*
>  	 * If any waiters have accumulated on the new page then
> 

