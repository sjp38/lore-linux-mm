Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A34BC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F91020645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:40:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Z9EV0qHl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F91020645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B24F46B000C; Tue, 23 Apr 2019 12:40:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7066B000D; Tue, 23 Apr 2019 12:40:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C48E6B000E; Tue, 23 Apr 2019 12:40:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 780706B000C
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:40:02 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n1so15110425qte.12
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:40:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OnmDEa4Vll+ER2XRN/87fZSs2s5ZyAbUlD8n6HCiMw8=;
        b=VH1qmd3wCCU860U8i5R+yhGd4UsHRQ2A7bt2vdDCEagqOhz5GlE/Ln88aw+MFSzGBI
         /PUmAo7F4/V+LT3EEfTgZLqR3JNfMOD1S7MJINcQ9t6tML0Cr06BczN48aYa3zEjJDeF
         R38i+sBHaGxpMZ/3EuHj+ye7bZnPDCUx0bAGVIfUaDv/SSr8hOLcDO72liC7k9hpgNXM
         TvDFIQSYTqbp4YLeLam4r62lu9s+zxvxdsIeUbefgsv4y3PsdUMlJOkkGXcCpmdvqRSG
         sTYDOsAzyrTWbF5Rfh55mOrCH7N1KU5EN5wL3O9ExEa81Z0IimUNGdldIBP8TUxYcBt5
         +YGw==
X-Gm-Message-State: APjAAAXbjmNqDjzG1sORaIqKfl5dmasMgFG7jBFu18+xSzWyKDdgK2yS
	Lvtk7MekbazUAsXoVoYEWz44ZP1AHt8/9aAWKql2s6Swl/bCxL4fI3UEmIjU9UGP106IJ3crr0W
	q9PKhUEgc0l/mDGSmOi8wXTjBsvviq7nXBsC0/JAIHX9lGy+0OIOdE9gQhi8F8luuKA==
X-Received: by 2002:a37:a7c4:: with SMTP id q187mr15511353qke.242.1556037602237;
        Tue, 23 Apr 2019 09:40:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1jVQGcVvWJP1QkdacbzxGMtBZzZvn3nH0EiHojad95ebzoOddHt3LyKBqR8y2ZgjziBKr
X-Received: by 2002:a37:a7c4:: with SMTP id q187mr15511317qke.242.1556037601642;
        Tue, 23 Apr 2019 09:40:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037601; cv=none;
        d=google.com; s=arc-20160816;
        b=Sutx8jdIZmmANLPz+0DYNaYzU1oH9FYbTPQ4AiifM46oUJjbJKRt3wFeLU35w9GL8W
         bILTsODOyvjqOcO6UXzaGmRUaPpVMUahTNXlEY3fKNXd0sAOpmz+daWIEjc7EBYt+tg/
         xfh6Ht5LUYwBvzKrhdHmT+poMlB6TREUJH9lWnqEnXEf/eJQJfLCtLnqP4HKpSF/jfUi
         71t6r8RDENXlJ6yV4hmXjzDbL39Af0WzL0yxDLziNoD3v2grugunOUeNVh7pMH7dcvXA
         VcvaMBVwq8Zf6FVCEVoX4T8oqcj7mOPsqxtrXvR4Z0gIvarW8CvsPlA6Glto5sBlhYVl
         fJPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=OnmDEa4Vll+ER2XRN/87fZSs2s5ZyAbUlD8n6HCiMw8=;
        b=E1nuI6zixuczfAw8BlrYjEDfZP7FM2nyCufnQ0CMDfeoiRexbqwrQqHA1oOPurIFcB
         0W2zxUAjRSgb9O9mhSyKMZOlFGXT8xngI63aDK7N+chdjOMPGTjh04NmXeq+Zv33ZUC9
         x2ne0qir045XeuqZ8EK7aP+A5648jDxFHJW1HM6jByfVGJ5VSS4Cn4f5Mxw4TT15nBg7
         po8TzqSg4mwqK1ejx8GPLA2Uw/w7sZLBp47xBgL5636hJCKbXkvZF9eVdEp73KGr05YW
         sMk9SkrIy+OwfoiehKb4HmYzoNj12CBaIeN0JoUXHxBI4gBudI7Etegm14AjwyMzqFAo
         CJPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Z9EV0qHl;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i7si1851971qkm.103.2019.04.23.09.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:40:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Z9EV0qHl;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3NGXbfI042863;
	Tue, 23 Apr 2019 16:39:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=OnmDEa4Vll+ER2XRN/87fZSs2s5ZyAbUlD8n6HCiMw8=;
 b=Z9EV0qHlZqVonQ+IibNlvzC8SfWpFIDQmk3Ix+qMsGNUBpraB2Fm957y7GLWq0Ez/E9D
 oqRookWBvmfmUZeJ7AX1DuCIYfBL2r9r4qX9ejVZ8oH/QJ4eJVOV8XRVup6N5yrg2o+B
 RLGZiKdvg88dXkgBgQJHvfd14Y0Dx1Sl3gt3r+tjsbQCP9yMCJ1KyWt1ItxbJiYA3UcF
 vDuDfYjdzosjJiWnkYj+idj5SygvAnS1b2kfeFNGYxI2ew9Cl+adWizRAt/1KCKkku1d
 itgeLkA11m7QQ2D5288Xdaulxt86kLbi1Ya02aE5hTY27qBQ1tHIpCXmbljBxu60XAXN 5g== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2ryrxcwn2c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 16:39:57 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3NGchkw116076;
	Tue, 23 Apr 2019 16:39:56 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2s0dwec9dy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 16:39:56 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3NGdn4o023727;
	Tue, 23 Apr 2019 16:39:49 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 23 Apr 2019 09:39:49 -0700
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>,
        Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
Date: Tue, 23 Apr 2019 09:39:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423071953.GC25106@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9236 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904230113
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9236 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904230113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/23/19 12:19 AM, Michal Hocko wrote:
> On Mon 22-04-19 21:07:28, Mike Kravetz wrote:
>> In our distro kernel, I am thinking about making allocations try "less hard"
>> on nodes where we start to see failures.  less hard == NORETRY/NORECLAIM.
>> I was going to try something like this on an upstream kernel when I noticed
>> that it seems like direct reclaim may never end/exit.  It 'may' exit, but I
>> instrumented __alloc_pages_slowpath() and saw it take well over an hour
>> before I 'tricked' it into exiting.
>>
>> [ 5916.248341] hpage_slow_alloc: jiffies 5295742  tries 2   node 0 success
>> [ 5916.249271]                   reclaim 5295741  compact 1
> 
> This is unexpected though. What does tries mean? Number of reclaim
> attempts? If yes could you enable tracing to see what takes so long in
> the reclaim path?

tries is the number of times we pass the 'retry:' label in
__alloc_pages_slowpath.  In this specific case, I am pretty sure all that
time is in one call to __alloc_pages_direct_reclaim.  My 'trick' to make this
succeed was to "echo 0 > nr_hugepages" in another shell.

>> This is where it stalled after "echo 4096 > nr_hugepages" on a little VM
>> with 8GB total memory.
>>
>> I have not started looking at the direct reclaim code to see exactly where
>> we may be stuck, or trying really hard.  My question is, "Is this expected
>> or should direct reclaim be somewhat bounded?"  With __alloc_pages_slowpath
>> getting 'stuck' in direct reclaim, the documented behavior for huge page
>> allocation is not going to happen.
> 
> Well, our "how hard to try for hugetlb pages" is quite arbitrary. We
> used to rety as long as at least order worth of pages have been
> reclaimed but that didn't make any sense since the lumpy reclaim was
> gone.

Yes, that is what I am seeing in our older distro kernel and I can at least
deal with that.

>       So the semantic has change to reclaim&compact as long as there is
> some progress. From what I understad above it seems that you are not
> thrashing and calling reclaim again and again but rather one reclaim
> round takes ages.

Correct

> That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
> looks like there is something wrong in the reclaim going on.

Ok, I will start digging into that.  Just wanted to make sure before I got
into it too deep.

BTW - This is very easy to reproduce.  Just try to allocate more huge pages
than will fit into memory.  I see this 'reclaim taking forever' behavior on
v5.1-rc5-mmotm-2019-04-19-14-53.  Looks like it was there in v5.0 as well.
-- 
Mike Kravetz

