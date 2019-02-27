Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E1ECC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 00:03:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD489218CD
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 00:03:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m1hW66jq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD489218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C8EE8E0004; Tue, 26 Feb 2019 19:03:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5529C8E0001; Tue, 26 Feb 2019 19:03:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41B378E0004; Tue, 26 Feb 2019 19:03:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6D58E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 19:03:42 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d18so10835382ywb.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 16:03:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VyO4ZrBMdrud25lLhZHSrL2iH8LB0S9KEvRat9Q0vfE=;
        b=C+rVChUr+FJoEKgOKxCfZg6mLS7KSkIDbBkHrHyAA0klgFF4Lq6+GTcCOg8xPy/YTu
         5+R7O9xaM2Z+Pn0BZzDvI7s+jQksIXROdPPzRgIStth2D1C1RHcbx9OC7OQ5SU0ZgbKL
         3gTbPvX6XZRDOT0imnjqFsiebtU9nhVOv5J3o8LUHBU+cNWXwyAE4TvbFOScKiii2FSt
         81gBNNrpblEeJbbnGceQdZAjwVbNfVPytD8O/bL9kspotAgUNVsav0oxWJF829ZMkMR8
         8Zxp99vNyN400V85Hrf2wXHCEoMCj5j3L20iH0mHg5N93FUPasUt9V7fotSBcey6Ekw5
         7MXw==
X-Gm-Message-State: AHQUAuYpfrxxcNFPin8/eTQxfxGVCHKWTUqnDfvKNATc2ScU8N1WYWFK
	7BKtxDpq2dfeR7ZNz/mSLIwQa3pnz52F5AnQkRSDPQTuuPKd4MQDrMQoFtrLXEmfjLAuT3VHI5A
	jtAB5mq6VadmqAveezqa8egqn3JZkyQLuUvlZ9PhDt9+LorEM9lJloJaAUIW+UtLoEw==
X-Received: by 2002:a25:804a:: with SMTP id a10mr6285553ybn.150.1551225821794;
        Tue, 26 Feb 2019 16:03:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8PrKRHIfVdtT+4+q2m370dNP1vG18G8hZz1afm40zc0uGQrs1WPw1H7Q9zaIhSZdu/tuz
X-Received: by 2002:a25:804a:: with SMTP id a10mr6285488ybn.150.1551225820952;
        Tue, 26 Feb 2019 16:03:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551225820; cv=none;
        d=google.com; s=arc-20160816;
        b=FqpzaehWbAQK9uoHGhF9BqTMnJNhOiKQKraDbdkKaqtYCezLGaCOh1GDlIJTziTR+P
         U04NMsFP6+EyMLtMd5ZnodTkuqHUEei2w1qwrWyCSK+wHU9u7KrI6WGcZbfdsGyPpA+i
         qfrO0adufI5kRWmDtiMY4XbUmn8txTfc3Bh3wfoWnYd9GvWBbZUi6Aan6JMnmJo16N4d
         eOA03B+IZWtsgH+KsZAJf08ynbsYaU2Jgo3wVI0vQ3iCudQyDL3dCm9N2VjHDsZw486b
         W9rcTxIhimhkxEC6iv7YtlOrrwuG1gHl04VRYXtCAkQBnPWqdrWBanCwQ8Bh6a+7NM+N
         fMaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=VyO4ZrBMdrud25lLhZHSrL2iH8LB0S9KEvRat9Q0vfE=;
        b=ckfcSzoHB5TBVrZC/1U4XdOpu2v8C5rG6vOLQ6v94HALFDkROOdsgIWLnB7foTNqlS
         AhlR68sp9qGNTDJWtadHMA4KuZjeI2vEosRrHd0z1PEQZh9GlPjfAJXitUnsgKzyvjD3
         KMGt6kmxbRX/viBYFaQ65PIpS71rwt376fQb9jJRJd60mrq/KmB8jhdPP+oZCLuSeh34
         utz38mEozdVsC0nWwlggJ6Py/YXfUg0L96sXFdnOEmbTngXCEwUkOy+2KNECCf0rVe39
         heSoG8pTEQRaTXpIy0wHQtb88p/LMnePxEwDgJuHL6ZU0Tu5t3ao4Qpugi8mTMQi6/xo
         Ay2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m1hW66jq;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m81si7790698ywm.415.2019.02.26.16.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 16:03:40 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m1hW66jq;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1QNxH1f033438;
	Wed, 27 Feb 2019 00:03:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=VyO4ZrBMdrud25lLhZHSrL2iH8LB0S9KEvRat9Q0vfE=;
 b=m1hW66jqcPB1r6qR7HDIFFGoFpEGxlCnx8ykYAwqwsZbJ2e4r5C9xsAZONtel47j9BEG
 j6gQrLZ+AEzsbkhhlXSEJlADG2a2DPP8DyOHxAkZobIiDu/8jcK8dEp2Mmawp52xdsSo
 CO6J8++gNHQ0ZjEpZPfc6y5WNn4GcqFWzOVMw5/W1GssG9OsF49JyayOZlQeAsGeJ8kd
 iGwD8nsyWJaAZDHvIR3G1w448ljXEW1JYF+qNqq6kSg6EBBDEnMiBKvnuMEWZPH12kwi
 Hj+KnDsOxW90jpV7/YUbRc4lY/PHEZMRs6D9Rrd/x4iQBb0tIH/4tM+fjoSguSzymlws hA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qtupe81m0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 00:03:27 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1R03Qcd008984
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 00:03:26 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1R03PHk020730;
	Wed, 27 Feb 2019 00:03:25 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 26 Feb 2019 16:03:24 -0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: Andrew Morton <akpm@linux-foundation.org>,
        David Rientjes <rientjes@google.com>
Cc: Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org,
        hughd@google.com, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
 <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
 <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
 <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
Date: Tue, 26 Feb 2019 16:03:23 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9179 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902260162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/26/19 2:36 PM, Andrew Morton wrote:
>> ...
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
>> nodemask_t *nodes_allowed,
> 
> Please tweak that email client to prevent the wordwraps.

Sorry about that.

>> +	/*
>> +	 * Check for a node specific request.  Adjust global count, but
>> +	 * restrict alloc/free to the specified node.
>> +	 */

Better comment might be:

	/*
	 * Check for a node specific request.
	 * Changing node specific huge page count may require a corresponding
	 * change to the global count.  In any case, the passed node mask
	 * (nodes_allowed) will restrict alloc/free to the specified node.
	 */

>> +	if (nid != NUMA_NO_NODE) {
>> +		unsigned long old_count = count;
>> +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
>> +		/*
>> +		 * If user specified count causes overflow, set to
>> +		 * largest possible value.
>> +		 */

Updated comment:
		/*
		 * User may have specified a large count value which caused the
		 * above calculation to overflow.  In this case, they wanted
		 * to allocate as many huge pages as possible.  Set count to
		 * largest possible value to align with their intention.
		 */

>> +		if (count < old_count)
>> +			count = ULONG_MAX;
>> +	}
> 
> The above two comments explain the code, but do not reveal the
> reasoning behind the policy decisions which that code implements.
> 
>> ...
>>
>> +	} else {
>>  		/*
>> -		 * per node hstate attribute: adjust count to global,
>> -		 * but restrict alloc/free to the specified node.
>> +		 * Node specific request, but we could not allocate
>> +		 * node mask.  Pass in ALL nodes, and clear nid.
>>  		 */
> 
> Ditto here, somewhat.

I was just going to update the comments and send you a new patch, but
but your comment got me thinking about this situation.  I did not really
change the way this code operates.  As a reminder, the original code is like:

NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);

if (nid == NUMA_NO_NODE) {
	/* do something */
} else if (nodes_allowed) {
	/* do something else */
} else {
	nodes_allowed = &node_states[N_MEMORY];
}

So, the only way we get to that final else if if we can not allocate
a node mask (kmalloc a few words).  Right?  I wonder why we should
even try to continue in this case.  Why not just return right there?

The specified count value is either a request to increase number of
huge pages or decrease.  If we can't allocate a few words, we certainly
are not going to find memory to create huge pages.  There 'might' be
surplus pages which can be converted to permanent pages.  But remember
this is a 'node specific' request and we can't allocate a mask to pass
down to the conversion routines.  So, chances are good we would operate
on the wrong node.  The same goes for a request to 'free' huge pages.
Since, we can't allocate a node mask we are likely to free them from
the wrong node.

Unless my reasoning above is incorrect, I think that final else block
in __nr_hugepages_store_common() is wrong.

Any additional thoughts?
-- 
Mike Kravetz

