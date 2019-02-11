Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA05BC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D29C2082F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:06:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xvO0dm9f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D29C2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D14688E018D; Mon, 11 Feb 2019 18:06:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC1928E0189; Mon, 11 Feb 2019 18:06:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B64808E018D; Mon, 11 Feb 2019 18:06:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 885048E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:06:37 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 135so1067989itk.5
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:06:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GJsg/6iWF2zbUF5f0Vm/sN97tzeqEZu2i2wvGlJUiI8=;
        b=KRY+8NHVxFWca/tX1QqXlwvK6Ry69vUEuUMew9g3mhWHPSzFkAVfjP7ij2ewZthP2K
         Ph9K/mjTonxtbkECbYFjb2Wxzq6uwpDtkuv1xf0ariIq48Nvs2jF3p1YOnaAa30p3c+g
         zHOp9atHGhhNem73CDHgAD7BApR7+Sn1sd5aCd7lQM+0VQx8c1XK0VJ9kkXOLz5HzhKO
         dWZjAAVoRoecueQsLFom+QAaOXcdVqv9hoKg0vKfGfUMD+Y+TIV6v2uxGaZZu7CAnBNe
         VqRxrj4y0CjQSl6QU95id7uRQSfLBjDh+ttolrl/2wX1mEhdf3U4bnYaAus94iysO3w3
         YvUw==
X-Gm-Message-State: AHQUAub0AcxJ6H7BoegFNFaOrQbfuA9Ffkc08ZoFjl5QlYA2Qc8uc9Uv
	wbrL8MsdOuJ8ZwY8lAvUdVkQXeuQXTvvLMwblLrt2VvwiFKx5sI034DtFIzoj0QO5pwhSkjbKDc
	jpbPuZibsaVQUvtnwfQysBs+cwkmm5uvpHgAQBsBIgTVpGHbXzPcm39yfHw5GjbYpLg==
X-Received: by 2002:a24:89:: with SMTP id 131mr306962ita.105.1549926397271;
        Mon, 11 Feb 2019 15:06:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYIIxiHBB3rQ427Tbyv28Jbnp1oGXFLcIhUU5+iiHgpdd6ERnuBRsa2/ipVQNeLxH6Do7jz
X-Received: by 2002:a24:89:: with SMTP id 131mr306925ita.105.1549926396399;
        Mon, 11 Feb 2019 15:06:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549926396; cv=none;
        d=google.com; s=arc-20160816;
        b=WZxlYl9ZJgwdbL2tQOwI3uWb3ucx0ZlWztVf0cz0YAw9Kng3YRTdQ7uSkIFTIY3Dif
         lSbi+GJIqwTDnKILy8sZTIT6Z2RnUahXo+d6fmq2oXapN10BBcVZ5Nu6w2AmsznS1TjR
         7gyngSGYywWtUIvH3PsvYwRr6TmiCJHN6mDymZgKaULPE3iZPY1kgrw+uUY/OKg851bV
         qtr+3A18H3AnQkXtgvREhA3Ys51Ib3cAE7gCPAceDoejWRfeNfBqttMDwvnsDrWZxaH+
         idzm5D4JXHGRaQFpdlV7CV0F2+29whEXUfJU7HuWgwPXszskMNuEfn3IuITg+0PBL7F5
         zbhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=GJsg/6iWF2zbUF5f0Vm/sN97tzeqEZu2i2wvGlJUiI8=;
        b=eWxFvkkG2qQQxrhH+d1wKtMLJjKbF0017So/91lnqiXXvw/Jwu5jKkYU0vCuCkJ+hB
         3jj/dN7kRNcXWQxutaS4Vldh99p+9h3Yn4u20iRCquyxtwVNZZlmgfk8mfbBy4V2Sor7
         djeBoklNzrrJ5jusR23NwvhHSbJ7FnqrzUBjs4qJ6kfZghhfl59Tezvb2x186nha8X43
         oNaG4rdZF0NSruQofBkbwh41z3y/TLnEO09OGdN9abqzoZgnDFQHSQk9kCWjWpR2QeCS
         1pBXrMWHNIVE/h7lrJpxufai0Q1DFYhiLZ7EWLW95G/RlZ1p0sHeZpL1k00juJE46XQ5
         lq2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xvO0dm9f;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f18si411693itf.9.2019.02.11.15.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:06:36 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xvO0dm9f;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMrrtW086848;
	Mon, 11 Feb 2019 23:06:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=GJsg/6iWF2zbUF5f0Vm/sN97tzeqEZu2i2wvGlJUiI8=;
 b=xvO0dm9fESHPjIZDvu+HKHoj2eJWeinOjCBZ+QYWFOdSF60P408v4p9TtaGBW7qbITto
 8zK4YKPRPTNxekrU3ZuDvHEU+GKYznMlSw4E1A0CbD4syRCzGCmwcrAd28idwUM3yxt5
 urxkhQG+65WuwkZrSh9/lMcq/AaF+H+yFmY2aYHTvVlCrVEgO8Pp7eDCv8I22ADu4YAy
 TXtUEgeN3Ru7uHh/hsQ4qLTlPcuuqE4tTKh7EaYEmec4l/qnviwUefPpjItnjvM8MeFX
 erWjId4332O5ve2POd7eXVZ6WzGgKQFY3bd5BFta+92j9oEhdACS4h1Yk12zWRYRV7Im Tw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2qhredrt4x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 23:06:31 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1BN6UkF005337
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 23:06:30 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BN6TUg027998;
	Mon, 11 Feb 2019 23:06:29 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 15:06:29 -0800
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso
 <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
 <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
 <07ce373a-d9ea-f3d3-35cc-5bc181901caf@oracle.com>
 <20190208073149.GA14423@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ffe58925-a301-6791-44d5-e3bec7f9ebf3@oracle.com>
Date: Mon, 11 Feb 2019 15:06:27 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190208073149.GA14423@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110163
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/19 11:31 PM, Naoya Horiguchi wrote:
> On Thu, Feb 07, 2019 at 09:50:30PM -0800, Mike Kravetz wrote:
>> On 2/7/19 6:31 PM, Naoya Horiguchi wrote:
>>> On Thu, Feb 07, 2019 at 10:50:55AM -0800, Mike Kravetz wrote:
>>>> On 1/30/19 1:14 PM, Mike Kravetz wrote:
>>>>> +++ b/fs/hugetlbfs/inode.c
>>>>> @@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
>>>>>  	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
>>>>>  	if (rc != MIGRATEPAGE_SUCCESS)
>>>>>  		return rc;
>>>>> +
>>>>> +	/*
>>>>> +	 * page_private is subpool pointer in hugetlb pages, transfer
>>>>> +	 * if needed.
>>>>> +	 */
>>>>> +	if (page_private(page) && !page_private(newpage)) {
>>>>> +		set_page_private(newpage, page_private(page));
>>>>> +		set_page_private(page, 0);
>>>
>>> You don't have to copy PagePrivate flag?
>>>
>>
>> Well my original thought was no.  For hugetlb pages, PagePrivate is not
>> associated with page_private.  It indicates a reservation was consumed.
>> It is set  when a hugetlb page is newly allocated and the allocation is
>> associated with a reservation and the global reservation count is
>> decremented.  When the page is added to the page cache or rmap,
>> PagePrivate is cleared.  If the page is free'ed before being added to page
>> cache or rmap, PagePrivate tells free_huge_page to restore (increment) the
>> reserve count as we did not 'instantiate' the page.
>>
>> So, PagePrivate is only set from the time a huge page is allocated until
>> it is added to page cache or rmap.  My original thought was that the page
>> could not be migrated during this time.  However, I am not sure if that
>> reasoning is correct.  The page is not locked, so it would appear that it
>> could be migrated?  But, if it can be migrated at this time then perhaps
>> there are bigger issues for the (hugetlb) page fault code?
> 
> In my understanding, free hugetlb pages are not expected to be passed to
> migrate_pages(), and currently that's ensured by each migration caller
> which checks and avoids free hugetlb pages on its own.
> migrate_pages() and its internal code are probably not aware of handling
> free hugetlb pages, so if they are accidentally passed to migration code,
> that's a big problem as you are concerned.
> So the above reasoning should work at least this assumption is correct.
> 
> Most of migration callers are not intersted in moving free hugepages.
> The one I'm not sure of is the code path from alloc_contig_range().
> If someone think it's worthwhile to migrate free hugepage to get bigger
> contiguous memory, he/she tries to enable that code path and the assumption
> will be broken.

You are correct.  We do not migrate free huge pages.  I was thinking more
about problems if we migrate a page while it is being added to a task's page
table as in hugetlb_no_page.

Commit bcc54222309c ("mm: hugetlb: introduce page_huge_active") addresses
this issue, but I believe there is a bug in the implementation.
isolate_huge_page contains this test:

	if (!page_huge_active(page) || !get_page_unless_zero(page)) {
		ret = false;
		goto unlock;
	}

If the condition is not met, then the huge page can be isolated and migrated.

In hugetlb_no_page, there is this block of code:

                page = alloc_huge_page(vma, haddr, 0);
                if (IS_ERR(page)) {
                        ret = vmf_error(PTR_ERR(page));
                        goto out;
                }
                clear_huge_page(page, address, pages_per_huge_page(h));
                __SetPageUptodate(page);
                set_page_huge_active(page);

                if (vma->vm_flags & VM_MAYSHARE) {
                        int err = huge_add_to_page_cache(page, mapping, idx);
                        if (err) {
                                put_page(page);
                                if (err == -EEXIST)
                                        goto retry;
                                goto out;
                        }
                } else {
                        lock_page(page);
                        if (unlikely(anon_vma_prepare(vma))) {
                                ret = VM_FAULT_OOM;
                                goto backout_unlocked;
                        }
                        anon_rmap = 1;
                }
        } else {

Note that we call set_page_huge_active BEFORE locking the page.  This
means that we can isolate the page and have migration take place while
we continue to add the page to page tables.  I was able to make this
happen by adding a udelay() after set_page_huge_active to simulate worst
case scheduling behavior.  It resulted in VM_BUG_ON while unlocking page.
My test had several threads faulting in huge pages.  Another thread was
offlining the memory blocks forcing migration.

To fix this, we need to delay the set_page_huge_active call until after
the page is locked.  I am testing a patch with this change.  Perhaps we
should even delay calling set_page_huge_active until we know there are
no errors and we know the page is actually in page tables?

While looking at this, I think there is another issue.  When a hugetlb
page is migrated, we do not migrate the 'page_huge_active' state of the
page.  That should be moved as the page is migrated.  Correct?
-- 
Mike Kravetz

