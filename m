Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BFB5C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 16:09:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C254E20862
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 16:09:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hTG+d6BL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C254E20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B9B96B0007; Tue, 14 May 2019 12:09:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 469626B0008; Tue, 14 May 2019 12:09:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 358D36B000A; Tue, 14 May 2019 12:09:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1DB46B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 12:09:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d5so11072382pga.3
        for <linux-mm@kvack.org>; Tue, 14 May 2019 09:09:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9uHuet9oULx3Dl16D7fXJItXNL536JRp038hEDJp0PY=;
        b=sHDbjdBm8YHEKMzPSpQYjwsYJ7fdly4CYukYUEh6+evBDsF4I5DBEuJhGcBCvmXcQW
         6yW3kl8KPCXKE0asZhz9jXYKDAAycnnp7TtPXnNEcgUEZLdK5B3KAW6zfR6UvD+yVyxl
         zNASQO5tjdUWUABrmFLWyQ/Qfo2zW86+LEjhLPf6Jm0SLDDZh3TOGk8psdicz8u50e7m
         jmx8iOlAA7aJ5fj65Dtm4Dxm6AQMBasIzGtiRFeN9dbViwsjrXP7/3t3LddK6aGUt8GZ
         0OiJ30qsFZXvg2mZOOGaRk+7/EawF4ZnV7SbEEIKtdhJgqCH4RfFgXdIGr7VMpvog6Z2
         NYTQ==
X-Gm-Message-State: APjAAAXgqfjnov8JGOWQoffCPJ/AaHVaRBUi1Ae2yfwSDhEDW7PWvR9F
	tKzCZX8/74gaDSYpuN07L8JbJYf0VCZstinZnIYVFeEHoV91ROQwaAgDRJyWOMTLUnMwqGpaRE5
	hEsRcwRqaHTLLeYapzt91OYVzBlt1j72fUarYZ4hjwNJUpiNOyioPh8Z6w1+weBXJxA==
X-Received: by 2002:a62:aa15:: with SMTP id e21mr41743950pff.140.1557850166481;
        Tue, 14 May 2019 09:09:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiPl9T85ReXYZvrpTFR8Sking1/o7R+2BjuIATc5hPegilQqrS6IjfsWZLkcWmqykfPFfC
X-Received: by 2002:a62:aa15:: with SMTP id e21mr41743834pff.140.1557850165222;
        Tue, 14 May 2019 09:09:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557850165; cv=none;
        d=google.com; s=arc-20160816;
        b=Mi5oW46aEyrFw9XGsXNCjNGhMO9ZYX8WQY9tfIrAjwlIxNBJX6wHh8TZZRNsiVP2lV
         bmk+FPlfAPr21132S1GrpgJkQCLTvfy3cfCGovtdcAGUQRs8xIFx4iXm4t6axP1DyiDX
         xrgjbm85B1TI40LWFOhvGIgTts3JhvJ06Z9btlJVzIh3GUPtiIhJCXEclURkdZARTlCR
         gBzq6s5QTbFzuG2+vnG8J0d4iV8UDKotqjCJhjMzSGYFOl9tuziEPvRoHNBEEg+VrQFy
         UxgrOTHTUhmUpwO3JdL0duQ63++b1hnytya6k3C7yEM36CaqRsvOy3R07ij5UYmczsbv
         waZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9uHuet9oULx3Dl16D7fXJItXNL536JRp038hEDJp0PY=;
        b=uoR2eKVi4wCcR34R2B8BdJV5EDBK+dt+kQEx+X9JKp1hWTZi4Tl+KW9xkn3Ejb46Nd
         nFSRc4UKGFsgkQ6ywz0q3riURVSdf/hoLn4aON9v7vFKbxCwpgOagw2KUoCPdIrD6JRi
         nJELvWhvf4okpK3ygYShkaHj1n6Riy9HQgbpYtnCk9ZwlbNlroHWKpZCJH8sAVapKccs
         Zby1o0KGLEQv5p/gJDH3XKF1+6wJboFXRE7bAS3JBQXZoHTgk1F+W5wBPkPqx+dmPxiY
         9cOvCCDu/KQERI4Igwz7Lj4CjsF5CA/zMkZN0YImcMSCX9JN5x5qyKxeSqMP78z9jrgP
         Cz6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hTG+d6BL;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c20si11297612pfn.256.2019.05.14.09.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 09:09:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hTG+d6BL;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EG46i6086549;
	Tue, 14 May 2019 16:09:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=9uHuet9oULx3Dl16D7fXJItXNL536JRp038hEDJp0PY=;
 b=hTG+d6BL9woEPC6IiRUTVyEe7702u71K9isLvRg/yPznlo1GVQ0LT2b+Z0buG/nZSaEZ
 D7r8jKL/vR6mkpUcDVsTXqQIQ25EQzoCqxK8ApEve4zw7qi5xJgjXF5QmmBw8nInnEe4
 ruWczm6LvllaInybKkZmJh21TR/sU6rvaDNSjvYGW+fpHgQuWO2waTQplqO/aMFYT4lb
 U51dRjQ2NM+augMoQrfEOKQFxn/0Ub4iujx8fR1AdnF8DUZMD4bMIp7F/LwkQbI2xDN4
 2cj8boMAppZHFdhkD+50H72XjiqJ1tUuTh2Sz5ir7JbJ5drl9bJLT0Xsogr45jCoaKmS Yw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2sdkwdqdnv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 16:09:11 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4EG7Kgo034402;
	Tue, 14 May 2019 16:09:11 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2se0tw887w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 16:09:10 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4EG98PO024162;
	Tue, 14 May 2019 16:09:09 GMT
Received: from ubuette (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 16:09:08 +0000
Date: Tue, 14 May 2019 09:09:06 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Larry Bassel <larry.bassel@oracle.com>, mike.kravetz@oracle.com,
        willy@infradead.org, dan.j.williams@intel.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 0/2] Share PMDs for FS/DAX on x86
Message-ID: <20190514160906.GB27569@ubuette>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <20190514122820.26zddpb27uxgrwzp@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514122820.26zddpb27uxgrwzp@box>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140113
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14 May 19 15:28, Kirill A. Shutemov wrote:
> On Thu, May 09, 2019 at 09:05:31AM -0700, Larry Bassel wrote:
> > This patchset implements sharing of page table entries pointing
> > to 2MiB pages (PMDs) for FS/DAX on x86.
> 
> -EPARSE.
> 
> How do you share entries? Entries do not take any space, page tables that
> cointain these entries do.

Yes, I'll correct this in v2.

> 
> Have you checked if the patch makes memory consumption any better. I have
> doubts in it.

Yes I have -- the following is debugging output I have from my testing.
The (admittedly simple) test case is two copies of a program that mmaps
1GiB of a DAX/XFS file (with 2MiB page size), touches the first page
(physical 200400000 in this case) and then sleeps forever.

sharing disabled:

(process A)
[  420.369975] pgd_index = fe
[  420.369975] pgd = 00000000e1ebf83b
[  420.369975] pgd_val = 8000000405ca8067
[  420.369976] pud_index = 100
[  420.369976] pud = 00000000bd7a7df0
[  420.369976] pud_val = 4058f9067
[  420.369977] pmd_index = 0
[  420.369977] pmd = 00000000791e93d4
[  420.369977] pmd_val = 84000002004008e7
[  420.369978] pmd huge
[  420.369978] page_addr = 200400000, page_offset = 0
[  420.369979] vaddr = 7f4000000000, paddr = 200400000

(process B)
[  420.370013] pgd_index = fe
[  420.370014] pgd = 00000000a2bac60d
[  420.370014] pgd_val = 8000000405a8f067
[  420.370015] pud_index = 100
[  420.370015] pud = 00000000dcc3ff1a
[  420.370015] pud_val = 3fc713067
[  420.370016] pmd_index = 0
[  420.370016] pmd = 000000006b4679db
[  420.370016] pmd_val = 84000002004008e7
[  420.370017] pmd huge
[  420.370017] page_addr = 200400000, page_offset = 0
[  420.370018] vaddr = 7f4000000000, paddr = 200400000

sharing enabled:

(process A)
[  696.992342] pgd_index = fe
[  696.992342] pgd = 000000009612024b
[  696.992343] pgd_val = 8000000404725067
[  696.992343] pud_index = 100
[  696.992343] pud = 00000000c98ab17c
[  696.992344] pud_val = 4038e3067
[  696.992344] pmd_index = 0
[  696.992344] pmd = 000000002437681b
[  696.992344] pmd_val = 84000002004008e7
[  696.992345] pmd huge
[  696.992345] page_addr = 200400000, page_offset = 0
[  696.992345] vaddr = 7f4000000000, paddr = 200400000

(process B)
[  696.992351] pgd_index = fe
[  696.992351] pgd = 0000000012326848
[  696.992352] pgd_val = 800000040a953067
[  696.992352] pud_index = 100
[  696.992352] pud = 00000000f989bcf6
[  696.992352] pud_val = 4038e3067
[  696.992353] pmd_index = 0
[  696.992353] pmd = 000000002437681b
[  696.992353] pmd_val = 84000002004008e7
[  696.992353] pmd huge
[  696.992354] page_addr = 200400000, page_offset = 0
[  696.992354] vaddr = 7f4000000000, paddr = 200400000

Note that in the sharing enabled case, the pud_val and pmd are
the same for the two processes. In the disabled case we
have two separate pmds (and so more memory was allocated).

Also, (though not visible from the output above) the second
process did not take a page fault as the virtual->physical mapping
was already established thanks to the sharing.

Larry

