Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A01A8C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:16:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C16B20896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:16:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="TczzrgYM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C16B20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E46DE6B0008; Tue, 11 Jun 2019 13:16:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1E716B000A; Tue, 11 Jun 2019 13:16:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE4566B000C; Tue, 11 Jun 2019 13:16:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B07026B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:16:34 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id k21so10107070ioj.3
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:16:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FRXVWJIPkmJFeMjoY+ciz/9M1AcGX3oAGMSsEXsUQc4=;
        b=qbLU6QhQx/QryrUwgnAmQDlwNK1qCYMjq0hhjoSHeoR7e3+JVxMaoNRneTDy3HhbFO
         OaV0zmd+i/htCZhZGC6inRsMI42DdeCJhqgcwUftVtpRPINtxCY8VylK26oH+jvtHhRC
         NnayxKzlfKpd0xdbjj0mMGgbzyuhL5JfDDwBdrdsRfwbgxcTOx0VMfA2TeFnLCI9xsY7
         hEMG4EVVXmHXztUHJ8SxDIedVUE8WZ2lbt7jF9T68C4MEa+G1jlI2TKFRcGSAdkGU4c0
         A+mkJ0w2Kce56Jooj4xKttly+mzUXJUXOcE5WZjatFit2vbvHr1omCxGQNTXJazsihjn
         CUAA==
X-Gm-Message-State: APjAAAVu1/uAUVrWDT3DCi3TFgh0xECXT6LLblyq3D/RdMsHpTBDe7Gy
	gY6AIH61Fg5apE1tYmzSShtsT/15TerpNlj1Hm1kYk4tzCWZbRtB4/BvoJycw2r5Wb+Saly3MS1
	CIRnjMM15YIYF16OSjsvHs0JZFJE+n8qoHP2jcKEqfzI28rR1klBBA/zgOU6KFEOy/w==
X-Received: by 2002:a24:9cc1:: with SMTP id b184mr10685855ite.81.1560273394383;
        Tue, 11 Jun 2019 10:16:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEUZDVitURq1Sfh+T9gN7Ft9ccP6DElRGwqD1D7Mjx5RVPmKtfZGk6pmcV3GvDRktl0NOg
X-Received: by 2002:a24:9cc1:: with SMTP id b184mr10685802ite.81.1560273393523;
        Tue, 11 Jun 2019 10:16:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560273393; cv=none;
        d=google.com; s=arc-20160816;
        b=X/Ec05g+aaaL5m4JZZiPRa6w20i1sGN6sLrVHj7QLgMII1Yl1JsJ/g2z8xDirG4Oit
         XaD/TuDMBNY7gQ0DIgU++unyty3tgno4O4LgS4/xxdc3bg9rnNMVJxegt6SwdegR5bzA
         eiIxPw0zzbfsn8qRXRPD8TvFANAr+WnM/cgGPn9m0S4Wu+a+4FrCs55G1JtE8K71lpWX
         nnxjFQ3ogH+O9kTfWUaBAQs/Q41CAlbquApzVkGPCUJyqsripSXcFA5YPBG3lUD++6VC
         W009kbWN9BXIPseOg67fYmydv1vLg8dOUku9dEks7B4hr9deuDLuvc8SspC3VBsBMEuV
         9uzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=FRXVWJIPkmJFeMjoY+ciz/9M1AcGX3oAGMSsEXsUQc4=;
        b=PUEr/8X4uA9hW9s6P8+NRt+wIMPXn19hxigQbHtJYXimtVGGduw3BeIyudbu2nFfuE
         9c4zouGnMsu+jWU5o4uo6IzKwODLpjuecvC+Ie+4ukv/J712p39g7XWeJN712/lfBHP7
         uRjn4/AXpgm4fQm/5BYB8zcvrUkN7RZspGC5JNYxhC/1Cb0wG9jPtQw0uxJAUFKKhSZM
         xoWE3y6DZFHn6pMyKSpGEMuIJrN2o7+0mATHvUZ50XrKsqJE81NdmYLVRobWVzzdBi1O
         v9NCj9sx67T6xDVn/od2JzwXKpPQNtoDHcUomuj/4hahYXNAC/+MrCWGIauMMqxgTvBQ
         v4TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TczzrgYM;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q23si9412703jac.89.2019.06.11.10.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 10:16:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=TczzrgYM;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BHDdFH022687;
	Tue, 11 Jun 2019 17:16:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=FRXVWJIPkmJFeMjoY+ciz/9M1AcGX3oAGMSsEXsUQc4=;
 b=TczzrgYMbt3/n5gl6dsdWiKXYMRRdAJ/TsGM2YoyeVTLRirZjvoIH55EQDebk9A4vZBo
 Gq4LZkULh8VT8TmOOrq5+z4VAP7WjGXqWzx9p7J6UB1CEzyAC8DNK9Xts3W7JEdvj1S5
 FEcGtlf2arGiRuhTj8iBaejwGnmtQ3VXddxzHCST9EC/uBcP4a8BqyOy3P6i16iLWn8b
 9Vti0heHbzqC40I65qNuwdJS1kzl0kbooJaQRHO9CnEzXo7ENuNfMEhmKaheJfrrTtQ6
 x+MdJtd0eRPHIYSpYI2z4yYyuCAhqEDjCOfxfEVtwAk5+D717638fA9LovnemDtSr3DN Bw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t04etpm98-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 17:16:21 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BHErDd138550;
	Tue, 11 Jun 2019 17:16:20 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t04hyfmnw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 17:16:07 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5BHG54t024839;
	Tue, 11 Jun 2019 17:16:05 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 10:16:04 -0700
Subject: Re: [PATCH v2 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu"
 <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <039dd97d-83f5-f71a-e78f-a451b0064903@oracle.com>
Date: Tue, 11 Jun 2019 10:16:03 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110110
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 1:18 AM, Naoya Horiguchi wrote:
> madvise(MADV_SOFT_OFFLINE) often returns -EBUSY when calling soft offline
> for hugepages with overcommitting enabled. That was caused by the suboptimal
> code in current soft-offline code. See the following part:
> 
>     ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>                             MIGRATE_SYNC, MR_MEMORY_FAILURE);
>     if (ret) {
>             ...
>     } else {
>             /*
>              * We set PG_hwpoison only when the migration source hugepage
>              * was successfully dissolved, because otherwise hwpoisoned
>              * hugepage remains on free hugepage list, then userspace will
>              * find it as SIGBUS by allocation failure. That's not expected
>              * in soft-offlining.
>              */
>             ret = dissolve_free_huge_page(page);
>             if (!ret) {
>                     if (set_hwpoison_free_buddy_page(page))
>                             num_poisoned_pages_inc();
>             }
>     }
>     return ret;
> 
> Here dissolve_free_huge_page() returns -EBUSY if the migration source page
> was freed into buddy in migrate_pages(), but even in that case we actually
> has a chance that set_hwpoison_free_buddy_page() succeeds. So that means
> current code gives up offlining too early now.
> 
> dissolve_free_huge_page() checks that a given hugepage is suitable for
> dissolving, where we should return success for !PageHuge() case because
> the given hugepage is considered as already dissolved.
> 
> This change also affects other callers of dissolve_free_huge_page(),
> which are cleaned up together.
> 
> Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Tested-by: Chen, Jerry T <jerry.t.chen@intel.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> Cc: <stable@vger.kernel.org> # v4.19+
> ---
>  mm/hugetlb.c        | 15 +++++++++------
>  mm/memory-failure.c |  5 +----
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git v5.2-rc3/mm/hugetlb.c v5.2-rc3_patched/mm/hugetlb.c
> index ac843d3..048d071 100644
> --- v5.2-rc3/mm/hugetlb.c
> +++ v5.2-rc3_patched/mm/hugetlb.c
> @@ -1519,7 +1519,12 @@ int dissolve_free_huge_page(struct page *page)

Please update the function description for dissolve_free_huge_page() as
well.  It currently says, "Returns -EBUSY if the dissolution fails because
a give page is not a free hugepage" which is no longer true as a result of
this change.

>  	int rc = -EBUSY;
>  
>  	spin_lock(&hugetlb_lock);
> -	if (PageHuge(page) && !page_count(page)) {
> +	if (!PageHuge(page)) {
> +		rc = 0;
> +		goto out;
> +	}
> +
> +	if (!page_count(page)) {
>  		struct page *head = compound_head(page);
>  		struct hstate *h = page_hstate(head);
>  		int nid = page_to_nid(head);
> @@ -1564,11 +1569,9 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << minimum_order) {
>  		page = pfn_to_page(pfn);
> -		if (PageHuge(page) && !page_count(page)) {
> -			rc = dissolve_free_huge_page(page);
> -			if (rc)
> -				break;
> -		}

We may want to consider keeping at least the PageHuge(page) check before
calling dissolve_free_huge_page().  dissolve_free_huge_pages is called as
part of memory offline processing.  We do not know if the memory to be offlined
contains huge pages or not.  With your changes, we are taking hugetlb_lock
on each call to dissolve_free_huge_page just to discover that the page is
not a huge page.

You 'could' add a PageHuge(page) check to dissolve_free_huge_page before
taking the lock.  However, you would need to check again after taking the
lock.
-- 
Mike Kravetz

