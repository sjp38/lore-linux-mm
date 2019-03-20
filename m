Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CB85C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:06:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1FFA2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 08:06:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FFA2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81B6B6B0003; Wed, 20 Mar 2019 04:06:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A69A6B0006; Wed, 20 Mar 2019 04:06:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 646876B0007; Wed, 20 Mar 2019 04:06:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABD66B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:06:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h15so1928364pgi.19
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:06:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=nF041Vc/yHIT36IP2Wtz0EO6gZwQ4FhNf2ZLoiUo3nA=;
        b=Z1wE8ptkdg9YYtoVScuhqKs2M7LGpAVmYfro1UjcqiLc5ZBiIAawEQ6Z2sYhCgL/im
         HEwSqEMoyTiUycQSJy6oz8G6zGOyOi+sCcF8pfaCLi6+oHTXRVs5S8D8H+TYqu4N0N3B
         Sx5VGDx84izgmRmvmBDR5qAhodmQZhIzTkr99JiJ8jMrmuTK405yjiXFeTE7sAJ3Nse2
         iySgvGB338flW5m8JIz2r+r1HQUvFgzPwz2pcXOyCxH92XVwdvz919GPof++7rn/3GnS
         qwfpaUDvB+4JSDVbJSvgA3ldkbbktGRyVPTFTznzBna8jy5+yl6vE7nb+73JO6z9ZarW
         0IhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUOuR6QVA4F6ySrOCIAe6hnWnfeLNbIHQLqd7QLMzKY6E7R8vS5
	moGp5HKUtm+vyDXwPEocU9rVf5O9fMAbBHLKCXrQjC1Ef4GNZS0YVrAnArbC3ejaYh+LYpbqnu7
	1ACWji3HwBQ/xMAi18naYbvIzdaciMMygzwq2i4y8dtIBHG5eDVqsi/G4kFyr+WVYig==
X-Received: by 2002:a17:902:784c:: with SMTP id e12mr7061200pln.117.1553069216800;
        Wed, 20 Mar 2019 01:06:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypA2GWnCSu7KaACa/p/LAZ3wP0DOUiPkwhruvfVw/6Qfykyt8GCKAW0fIu4pE9XoOl7luT
X-Received: by 2002:a17:902:784c:: with SMTP id e12mr7061145pln.117.1553069215831;
        Wed, 20 Mar 2019 01:06:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553069215; cv=none;
        d=google.com; s=arc-20160816;
        b=aoLowzENa0PjHjTc3TZXjIPULmu1Wg8y3pva8XueVU2+y7RjVyyjTx/LJgv8atLBwC
         KlJtzrWlsfzVYrSzJCmgkmqwR2cYEoAnnw541vekF/nwWhj8dnATfq+rWGnXFVJfFiP6
         T8sE7a5xfGjPFCXwxK6Fhje7EZqOfGKO+75Bi5NUG201xd8ggHmNlPhLQQioaR6rAmLw
         yE7Ciwco8d3P/yyFBUUnU6sVlF0GR/9laXt+NqFn4M6skZhi/vJ7H9PpgMMdaxmyFr4r
         nY+0K9eDW6RW+vh49cpJkkMJudhuy0fAr4TJOqzoPxGFsIau3dgySn6k/HXK4lAFQDwq
         QP4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=nF041Vc/yHIT36IP2Wtz0EO6gZwQ4FhNf2ZLoiUo3nA=;
        b=V+MHb5CiX4rlQuglP0FPpayY79Oxo9fbnUq3PrRsnoZ2JfwSdB4kAoGP1nn/D1+h78
         PNtCZWcoqViPQyehSHXT8L9crVXOJx4lVT3u8V1x1/sGN6t+3kZMYVYBbnIxI7sr++TJ
         I5DobWDS1BcSFiUWYwpeuXSa3QCEOZNeHEqElc6X2UXNhOl76KWW8eM0/Opx/Xprwjsb
         fcWKbRQiVUa0lXSiEcFZVk5faaaVOfM82Z8VShx+ZhzKMGU+oIucGDJtIdqdCGZ19gDi
         ZyWko9bFowoCEQ012jOarQUhrEiP3J3cKTbTeT5R3gDup6tKGTsXTh9xxH8AaeIpu34B
         65/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j134si1248091pgc.42.2019.03.20.01.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 01:06:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2K85vae126416
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:06:55 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbfykn82m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 04:06:54 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 20 Mar 2019 08:06:46 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 20 Mar 2019 08:06:41 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2K86k5o26214620
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 08:06:46 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C298C4C046;
	Wed, 20 Mar 2019 08:06:46 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1503C4C040;
	Wed, 20 Mar 2019 08:06:45 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.96])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 20 Mar 2019 08:06:44 +0000 (GMT)
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
In-Reply-To: <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com> <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com> <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com> <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com> <871s3aqfup.fsf@linux.ibm.com> <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
Date: Wed, 20 Mar 2019 13:36:43 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19032008-0020-0000-0000-000003257506
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032008-0021-0000-0000-00002177926D
Message-Id: <87bm267ywc.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-20_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=811 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903200068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

>
>> Now what will be page size used for mapping vmemmap?
>
> That's up to the architecture's vmemmap_populate() implementation.
>
>> Architectures
>> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
>> device-dax with struct page in the device will have pfn reserve area aligned
>> to PAGE_SIZE with the above example? We can't map that using
>> PMD_SIZE page size?
>
> IIUC, that's a different alignment. Currently that's handled by
> padding the reservation area up to a section (128MB on x86) boundary,
> but I'm working on patches to allow sub-section sized ranges to be
> mapped.

I am missing something w.r.t code. The below code align that using nd_pfn->align

	if (nd_pfn->mode == PFN_MODE_PMEM) {
		unsigned long memmap_size;

		/*
		 * vmemmap_populate_hugepages() allocates the memmap array in
		 * HPAGE_SIZE chunks.
		 */
		memmap_size = ALIGN(64 * npfns, HPAGE_SIZE);
		offset = ALIGN(start + SZ_8K + memmap_size + dax_label_reserve,
				nd_pfn->align) - start;
      }

IIUC that is finding the offset where to put vmemmap start. And that has
to be aligned to the page size with which we may end up mapping vmemmap
area right?

Yes we find the npfns by aligning up using PAGES_PER_SECTION. But that
is to compute howmany pfns we should map for this pfn dev right?
	
-aneesh

