Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8FA0C282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 448BF206B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:13:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GeW81E+F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 448BF206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C54D78E0004; Tue, 12 Feb 2019 19:13:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDC028E0001; Tue, 12 Feb 2019 19:13:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA34F8E0004; Tue, 12 Feb 2019 19:13:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4548E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:13:17 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id f137so1021017ita.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:13:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i/DRl5Ab8RJflfKksWYbm6JgjdqdldbLWDY4G+e/3hk=;
        b=JR+oTxogcTY9eWXVcv22ZenxC13x/gHb8+ggh0we99ol8n110Zf5l4ScbvYvvpsmfz
         X9DtgvHLYYF8/ugDKztHIYfvtYv7pjhMb2wguouab5nF8P1E3LT9ju38PJ/Ve6W3cQNo
         ZLng66ldalDe39E+zqObC/Gy1O/N4cXr84TDPcBUJ2ubHWPXwEsv08k3Fo5e3E+6MZ9D
         hIpKtql+b9rantE4F8GK1rFRaoHIriURXMSrTdkzAClmIHU6y/KB1ZpKgtDJMDmPUHls
         j0CF7U4SACGUj2QB1FaQz+nD9h6Thfx9zjhEAk+hamHWIILdUDkTBQG9aFkYqa3uEtup
         iqzA==
X-Gm-Message-State: AHQUAuYRyXZGJS4cYpKWsXdiRNRYARqwsBu+dtTwiUda1LOAUL8P2ZBf
	gMBz4qUHe+WM5BxtpFsc4KThdHvQ6BxLoUXzhBBw4FvYwY6ebmHq+n0krnnlLx16RFDdU47ppun
	MlaO8AqKc7tkidSF63wOoNh1zAS+dD3iG57ROVex4IpzGmn4WOKStGpr41VB1PHBopw==
X-Received: by 2002:a24:cc05:: with SMTP id x5mr857222itf.82.1550016797282;
        Tue, 12 Feb 2019 16:13:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYLZTs35+uqqD3PXTXcMI58bXwLOn8j61+gz3CkViVhywPiphFex2JvTkkx0gZXukGde30A
X-Received: by 2002:a24:cc05:: with SMTP id x5mr857202itf.82.1550016796491;
        Tue, 12 Feb 2019 16:13:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550016796; cv=none;
        d=google.com; s=arc-20160816;
        b=rqaKyK5GIer18q1hlCc1B7vYSuwsWZBjvP3bxPNRbN/0AFK7ou6V3mo8zE1imnDhxc
         3bnV13cYx4prgdEH/1NFfq1OkwO/JhnWAl8GEp5myiQfIPjt77abBkeNDgR1CahvyNlA
         ig+vhd+E1d1q3Xp2cm7HkZWg+1CJz9Nig11bZcdNg7CHM1inNSvGXIiw7KMG+R1ghu8Q
         1V792yTb9OS+qkmMM3iqlt5EZXa2cee0bEMSReo+UPkDh7QCm5gwH1C3wWqeG3xLgkzV
         OW6OETIvg/c3ZVS9DojQ1ctL+uVPYwtjj55XnAA/9qIQL/Ff9JNkOcirmxAudNFSpB25
         O34A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=i/DRl5Ab8RJflfKksWYbm6JgjdqdldbLWDY4G+e/3hk=;
        b=BVSoPEB3obrzLd1w2e0anlZYaKkNjpJEgugrS0R4inBAY1zKJdfWthvR6DYU3AOf0W
         xZsLcVv+pmdznhFuwsPz5wpJVkevj6/Zz5PE34E1b9Zek5mo8fmFNEy0/am0SuFLye8q
         xhzjSpgNNZOjY1ibILF3Va+VPf1hI9rmcpT6ZNgpR/KH96feua1aOummHa5O4QBobH0T
         52hvws6eE1Yvb8oYYXQFh2Anvur2sE3Hz0RyxJUT8U7tjaXkVxCtneWs+9gQ3w7EDUlp
         1XGcpAi19jANaxigcPM0Qyeg7cLngVCLe83JPB6ADGa8KmmTY+vhFGPb9N7GrpcXLwHv
         yIMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GeW81E+F;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i12si2037670itb.82.2019.02.12.16.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 16:13:16 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GeW81E+F;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1D03osC127411;
	Wed, 13 Feb 2019 00:13:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=i/DRl5Ab8RJflfKksWYbm6JgjdqdldbLWDY4G+e/3hk=;
 b=GeW81E+FpIl/jZBIKGaVE6nhvYyck8B5ybuMX41uaLSwmFrhYOSgD5pLycllWGeHKRo3
 zbY2QGemmqeIsasHRI+w3ykVQv+nfU/JILNsWaLBph79FapWe3vNZ7DphmMsIFnTnb1s
 T3rY4QG+chT/RvrGKYJOKhCTeJeLEpCONm/3svxaupyUeBHxEDLr2MWS+QemYSriAd+n
 B5dKzMgE855IeW4jNebnQo+Xa8cMWP9aBFET4xzIRZbVXyMzH75eIvAGD1rky/eD0Heu
 FeFRjZX+z/L9xxUXKVWOKdZa86SxU5offVhBusMxzx2emOye36SflqgHxkEBibvaw+hM mA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qhre5f3sx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 00:13:13 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1D0D7Mm008885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 00:13:07 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1D0D60c022977;
	Wed, 13 Feb 2019 00:13:06 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 16:13:06 -0800
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
To: Michal Hocko <mhocko@kernel.org>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, anthony.yznaga@oracle.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190208090604.975-1-osalvador@suse.de>
 <20190212083329.GN15609@dhcp22.suse.cz>
 <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
 <20190212144026.GY15609@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <52f7a47c-4a8b-c06d-04c0-48d9bb43823b@oracle.com>
Date: Tue, 12 Feb 2019 16:13:05 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190212144026.GY15609@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 6:40 AM, Michal Hocko wrote:
> On Tue 12-02-19 14:45:49, Oscar Salvador wrote:
>> On Tue, Feb 12, 2019 at 09:33:29AM +0100, Michal Hocko wrote:
>>>>  
>>>>  		if (PageHuge(page)) {
>>>>  			struct page *head = compound_head(page);
>>>> -			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
>>>>  			if (compound_order(head) > PFN_SECTION_SHIFT) {
>>>>  				ret = -EBUSY;
>>>>  				break;
>>>>  			}
>>>
>>> Why are we doing this, btw? 
>>
>> I assume you are referring to:
>>
>>>>                     if (compound_order(head) > PFN_SECTION_SHIFT) {
>>>>                             ret = -EBUSY;
>>>>                             break;
>>>>                     }
> 
> yes.
> 
>> I thought it was in case we stumble upon a gigantic page, and commit
>> (c8721bbbdd36 mm: memory-hotplug: enable memory hotplug to handle hugepage)
>> confirms it.
>>
>> But I am not really sure if the above condition would still hold on powerpc,
>> I wanted to check it but it is a bit more tricky than it is in x86_64 because
>> of the different hugetlb sizes.
>> Could it be that the above condition is not true, but still the order of that
>> hugetlb page goes beyond MAX_ORDER? It is something I have to check.

Well, commit 94310cbcaa3c ("mm/madvise: enable (soft|hard) offline of
HugeTLB pages at PGD level") should have allowed migration of gigantic
pages.  I believe it was added for 16GB pages on powerpc.  However, due
to subsequent changes I suspsect this no longer works.

> This check doesn't make much sense in principle. Why should we bail out
> based on a section size? We are offlining a pfn range. All that we care
> about is whether the hugetlb is migrateable.

Yes.  Do note that the do_migrate_range is only called from __offline_pages
with a start_pfn that was returned by scan_movable_pages.  scan_movable_pages
has the hugepage_migration_supported check for PageHuge pages.  So, it would
seem to be redundant to do another check in do_migrate_range.

-- 
Mike Kravetz

