Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC41DC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:42:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9455920870
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:42:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9455920870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 220D88E0002; Wed, 30 Jan 2019 23:42:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CF868E0001; Wed, 30 Jan 2019 23:42:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BF958E0002; Wed, 30 Jan 2019 23:42:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D34FF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:42:29 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so2275329qte.10
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:42:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=88yMNzIxrfRejbgfj/UAb2iKFaK7GYyrZl3G3NtWWyU=;
        b=N7AmJc4qU+bKq6l5Smrnp1BvToWMOmAfkwgaXyHBga1ylwNCAjwFF7vOY77Ewx8Hou
         ROSKhQWiu7f4nI9mE//I6d++QASb+SZSii6lNdpyEjLFcqlyEpDKsmffuIxIDcckZFvY
         lodGPfJdHH40IGkuo5tcvHi2jCWVgKRHA9HK3XqkP0vGXlYFJn9/gqncvjRP2HkICQVz
         uBjza2TrWN4eGGRpXUAdmUOfFUWGGCNnKDUPqbUTQYanNVilB1gtIvHR9xXtenEXxtUp
         rrvvI3kGX9VenTRxjr3lRPoRgXFrpV78KdkrBCUtZuCibxL2qGVKbFszJdVM/29W8Mza
         nxHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukc7ZpjWT96w1gJuZrTNOn+QzouxtBAAFlf+gVXc0d4BRYK0hudk
	6mbMa7JBTVIxRhJAHYy5YjNeO1vVcWIbLCf3dx8tJWNm3ev/y/NSQkIxWlDBA0vu0DbMRX08krz
	jzbk0vM6uNEXywcyCzABJ4wgnWM8YyjZXbZw7KLnJsp+LSBta+60WPZcUNlyGah2iUA==
X-Received: by 2002:a0c:db04:: with SMTP id d4mr30889907qvk.114.1548909749635;
        Wed, 30 Jan 2019 20:42:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5lhjQsxYOf1+0hk3CdiJJaareZA3myjsyzzvU5B7hlClSSqyeVh+5QvCx120lCzPEUPM69
X-Received: by 2002:a0c:db04:: with SMTP id d4mr30889887qvk.114.1548909748987;
        Wed, 30 Jan 2019 20:42:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548909748; cv=none;
        d=google.com; s=arc-20160816;
        b=Cut9YvCedMv8SsbBBmvQk8WMACf8jGQAFBoRr3LbGjNk7yJsjEt2g7C9il6JTsUn0/
         o4djvbQEog43Ewz4Pw2HCWacz33SaIfsMQtQwfFcP55g7oISSE0YnhEKNzW2rh7ibzrH
         Rpy4ZdcBYGsRSwRGQOZwG9K7hzeLsdtAGFVdOFOe7CEraOwIODCescp4pXEAqC5J7uJs
         wWIkbMvZClwpefkulSBm4f1BIdK2knzv7Wt07/A/cz9I+hgZzYaSbfPYBpCuifhM+s33
         3CUg7uUwQj+oa3a3DRA5t/QSkIHa1RIpnPb1NKikrC02UkY4uvYWvOmGtzF3O1GcQgai
         xdHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=88yMNzIxrfRejbgfj/UAb2iKFaK7GYyrZl3G3NtWWyU=;
        b=IFV37lKyQSyLlJYQ1P9hCC46q9Ox9SSAtQwauv7DPYASVOgs7pMaqp7OPs3q208Aow
         mFdyLDP7CJtOPFsqOmpKHiUn1e4Nde9AZJwKC7zsWODkFZEPS8c/EdsTbD5VvVDWp/NZ
         dG06MtL+KgIRoG1uFeYOE3K2MDYaMArkJ+ZTFNcBR/sE1XAx2dQeAki0t59FiyK+tP24
         jsDDPmaSGhDKqqW9pnsuCuCBqvNF9Y7extW/UxMjik8DyXWNkyJXlIvCeB1xgbpwpThb
         pIjISdgSv2WTGRIxIyWI4MTgb0BjWHgHPUGVkjhP55weynTxPApKrWwDYV6DPovwcRqc
         M8Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e97si2422847qtb.180.2019.01.30.20.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 20:42:28 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V4YSbM088902
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:42:28 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qbnmvsxux-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:42:28 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 31 Jan 2019 04:42:26 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 04:42:23 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V4gMYH8061232
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 04:42:22 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4B029A4054;
	Thu, 31 Jan 2019 04:42:22 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E68E0A405F;
	Thu, 31 Jan 2019 04:42:19 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.38.122])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 31 Jan 2019 04:42:19 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org,
        Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
        David Gibson <david@gibson.dropbear.id.au>,
        Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH V7 3/4] powerpc/mm/iommu: Allow migration of cma allocated pages during mm_iommu_do_alloc
In-Reply-To: <874l9qqsz4.fsf@concordia.ellerman.id.au>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com> <20190114095438.32470-5-aneesh.kumar@linux.ibm.com> <874l9qqsz4.fsf@concordia.ellerman.id.au>
Date: Thu, 31 Jan 2019 10:12:17 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19013104-4275-0000-0000-000003081F78
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013104-4276-0000-0000-00003816274C
Message-Id: <87pnsdo2ty.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310036
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michael Ellerman <mpe@ellerman.id.au> writes:

> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>
>> The current code doesn't do page migration if the page allocated is a compound page.
>> With HugeTLB migration support, we can end up allocating hugetlb pages from
>> CMA region. Also, THP pages can be allocated from CMA region. This patch updates
>> the code to handle compound pages correctly. The patch also switches to a single
>> get_user_pages with the right count, instead of doing one get_user_pages per page.
>> That avoids reading page table multiple times.
>
> It's not very obvious from the above description that the migration
> logic is now being done by get_user_pages_longterm(), it just looks like
> it's all being deleted in this patch. Would be good to mention that.
>
>> Since these page reference updates are long term pin, switch to
>> get_user_pages_longterm. That makes sure we fail correctly if the guest RAM
>> is backed by DAX pages.
>
> Can you explain that in more detail?

DAX pages lifetime is dictated by file system rules and as such, we need
to make sure that we free these pages on operations like truncate and
punch hole. If we have long term pin on these pages, which are mostly
return to userspace with elevated page count, the entity holding the
long term pin may not be aware of the fact that file got truncated and
the file system blocks possibly got reused. That can result in corruption.

Work is going on to solve this issue by either making operations like
truncate wait or to make these elevated reference counted page/file
system blocks not to be released back to the file system free list.

Till then we prevent long term pin on DAX pages.

Now that we have an API for long term pin, we should ideally be using
that in the vfio code.


>
>> The patch also converts the hpas member of mm_iommu_table_group_mem_t to a union.
>> We use the same storage location to store pointers to struct page. We cannot
>> update all the code path use struct page *, because we access hpas in real mode
>> and we can't do that struct page * to pfn conversion in real mode.
>
> That's a pain, it's asking for bugs mixing two different values in the
> same array. But I guess it's the least worst option.
>
> It sounds like that's a separate change you could do in a separate
> patch. But it's not, because it's tied to the fact that we're doing a
> single GUP call.

-aneesh

