Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72431C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:09:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29CB92146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:09:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29CB92146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74C16B0006; Wed, 20 Mar 2019 04:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFE036B0007; Wed, 20 Mar 2019 04:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C6636B0008; Wed, 20 Mar 2019 04:09:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5901E6B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:09:26 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v3so1960676pgk.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:09:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=vXOhmctW8NRvIiQbWlUNeY5u33WXV4I4+p64PjC/ZKY=;
        b=L0xwmVw/Vp3EdJCuhuadZlfg3PLaJuO3ok+7e/oaO84WRztnTS+whfvk4+Ehcbmk8M
         NtP8kDtMWHN++SYjb2UkcGdc6S34F82oA0aDUr4F9hVGu1kmUFgkqtm7zBfGyemFgtcy
         OrQEXNlqk0AnRoXInaYwt0vM0jUNJZ/XqLZKHGxKrLNh1DlE/tibDEbjJmXk212Gv2wr
         5OhgwH4I73XUh4sAFVzJXqhEuuu3ceeWNvC3NcUX8NWqF9dUZI7VkHqgxf3fD4O8iJsJ
         QXDhZvgP1Q/mYaQ7mbXJdXFA3mx0j0yYob+DJmmNHOIVXyWMDQTGKkHSuwhey1bQ2iVe
         VKGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXxquMZJKFLLhaXIGEsbkXelJ0vew3ylJrH4lS4N2PGVkMMt0L9
	OALp62YxiDnuRRiqbq2cznYrXTm8SQg8bNtH0nQL1t1C/TYApG3VM1hn5azEDpNuZQ5FZhbn8Zv
	BTlVyOcFwP8PU8i8Q/aDoKTBIYQ5PtWJcBbPZi5rhuoG7bMXsnrGmNwZk7IUVRD8ZLw==
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr6641799pla.139.1553069366012;
        Wed, 20 Mar 2019 01:09:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxI6JMMws4zyUCa9nJZDIrdJdwtc6XAgh73EINAWaJPhO3iH5s0iWK/MqVvE0JKTHE4DT+2
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr6641748pla.139.1553069365241;
        Wed, 20 Mar 2019 01:09:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553069365; cv=none;
        d=google.com; s=arc-20160816;
        b=EGQd3EG5Uwr/HHiwbhxs+dzLgC5rxdZO1kAwntZcED1jfb5bKGAs9w9APK9SI9hB2e
         fc+JJ8RpdtngahuP5crz8Z+KYdQZsVLXcluQNG1ZAbrHazbZd8I/YWKVHa5ecI92Dlku
         XbPRIxy6Wl2h1ShTCFyJhfiUNiDu1lwB62wRz59lrhvuMfXGuF6OYvsdNb9p4tYVHqPf
         hm4twJPKQSVqwf+Ne18RclGPJut6nEZYdziTyCPNM8VYDlLz/O0UqHJ7MSD32+STsAQy
         T2XIyDiszYdTnAUXnn0gJyN3BzzIP5nkIdYrJCyPGw2t+qrj32TVJfjIeHaj40kNzSFO
         7imw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=vXOhmctW8NRvIiQbWlUNeY5u33WXV4I4+p64PjC/ZKY=;
        b=aSPFx5423DUz3Kjx+TUN3WK4Uf29PYBet+yZisplUI8u/j3j66y/kUfrpKaHXpAZqz
         1Cud0YS8DhKOqoGEAxPr/BUeZqhD69VZXUwLEoNi51MbTcQynkhOmqTIsEKCklYHmHyV
         RQwvgdoIio+y8QakFGRoz3qR9QPFPQKyg6kYZoYzjKNQYNQUsACg0sog5CyZdojlqtat
         aqRoQccfEhHE+CMHWcjt8f5cwr001/Y+G2L/evSFtOcji2bt3irrlBTLiU8oKGrhFz2t
         LXPFiPTHtizG67NQ/8n/+v1rGpOKIZ9jVDKzafaDpK6lqdXfTQEbsjLbK/9TpbzG57Bb
         94Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o188si1143121pga.297.2019.03.20.01.09.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 01:09:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2K85wHu126441
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:09:24 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbfykncub-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:09:24 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 20 Mar 2019 08:09:17 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 20 Mar 2019 08:09:14 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2K89H8X49676504
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 08:09:17 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4F9D14204D;
	Wed, 20 Mar 2019 08:09:17 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB6D34203F;
	Wed, 20 Mar 2019 08:09:15 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.96])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 20 Mar 2019 08:09:15 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>, Ross Zwisler <zwisler@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
In-Reply-To: <87bm267ywc.fsf@linux.ibm.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com> <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com> <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com> <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com> <871s3aqfup.fsf@linux.ibm.com> <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com> <87bm267ywc.fsf@linux.ibm.com>
Date: Wed, 20 Mar 2019 13:39:14 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19032008-0008-0000-0000-000002CF7022
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032008-0009-0000-0000-0000223B8633
Message-Id: <878sxa7ys5.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-20_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903200068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> writes:

> Dan Williams <dan.j.williams@intel.com> writes:
>
>>
>>> Now what will be page size used for mapping vmemmap?
>>
>> That's up to the architecture's vmemmap_populate() implementation.
>>
>>> Architectures
>>> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
>>> device-dax with struct page in the device will have pfn reserve area aligned
>>> to PAGE_SIZE with the above example? We can't map that using
>>> PMD_SIZE page size?
>>
>> IIUC, that's a different alignment. Currently that's handled by
>> padding the reservation area up to a section (128MB on x86) boundary,
>> but I'm working on patches to allow sub-section sized ranges to be
>> mapped.
>
> I am missing something w.r.t code. The below code align that using nd_pfn->align
>
> 	if (nd_pfn->mode == PFN_MODE_PMEM) {
> 		unsigned long memmap_size;
>
> 		/*
> 		 * vmemmap_populate_hugepages() allocates the memmap array in
> 		 * HPAGE_SIZE chunks.
> 		 */
> 		memmap_size = ALIGN(64 * npfns, HPAGE_SIZE);
> 		offset = ALIGN(start + SZ_8K + memmap_size + dax_label_reserve,
> 				nd_pfn->align) - start;
>       }
>
> IIUC that is finding the offset where to put vmemmap start. And that has
> to be aligned to the page size with which we may end up mapping vmemmap
> area right?
>
> Yes we find the npfns by aligning up using PAGES_PER_SECTION. But that
> is to compute howmany pfns we should map for this pfn dev right?
> 	

Also i guess those 4K assumptions there is wrong?

modified   drivers/nvdimm/pfn_devs.c
@@ -783,7 +783,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);


-aneesh

