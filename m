Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD37C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29052222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:06:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29052222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99AD58E0002; Thu, 14 Feb 2019 04:06:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 955798E0001; Thu, 14 Feb 2019 04:06:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 814938E0002; Thu, 14 Feb 2019 04:06:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5629F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:06:40 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id s4so4930280qts.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:06:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=At7aqtjicqewEtGyqeb+vScQZJaX6SY6pPwpi9xbAXE=;
        b=qxQ9dclIvDYoalKAt95GRRV9WFMDN70uMlp1yktpyVnwEclngYAu51o5T958YwDE3S
         XVpcZtnEe4w9YQzkpX1ajNZmK6vjYCxo3rZTQs7pn+pRewWwI3SGaBvF/tbvB0nQEPEn
         BKP3MGBTexjN0UDl2lE4Wbmz2ZkZCN75F/VQZi/GQySSiGiWvZ+x2IDHNgr9sg6m4GRr
         DMLanstL6WjWvXlS239A6tugCM4V+ZNyjsZqQ+jtNv0bD+ZwKtfLOBY2xjlonf/9UYi8
         Xl712mLkQWxz6HNpOm03BvZGZqn5Ci+/ZQXLCNednZyxNWyyKyEn7E5Ep9H2wQqhoZsm
         oYGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubIwe+79xBJEMXFfw2ml5OZf6f4ZF5mZWQ8ioXkhsbj2MJbKUAf
	18rgDwEZJaXwecjxgBVDJvCwHII2oEDyzl8pcMr0OJHdJh4MdPkmaK4SIuPdDSYjQKcCCdF25sA
	Me6GRaBipRPoDe1/U+9nfiTE1+kmlKaAj2f/oXUUCe10eLjuF9lkxy7f+xAt4a2/2iw==
X-Received: by 2002:a05:620a:136d:: with SMTP id d13mr1971994qkl.256.1550135200071;
        Thu, 14 Feb 2019 01:06:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQQRPfZ1P2HMlPTZXH26YqkJwbjgFey2w6qrAXC0QvYSIiy4fNM81ySD/IzDgJGGfMmY1x
X-Received: by 2002:a05:620a:136d:: with SMTP id d13mr1971966qkl.256.1550135199480;
        Thu, 14 Feb 2019 01:06:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550135199; cv=none;
        d=google.com; s=arc-20160816;
        b=SSf+dpSdQ5dzTWKGLVYseYASNQQVatZzzSGFjdQFL9T5yY3LqD+yjlCK8d+8fxRM2i
         OloR2E5ET+Vk4tv5S8opdr6RUAxAr0m/A7jkvUQQK+yyl9FZQpwBx7JgZWDmCPNbTSnV
         IaRszUyYCWgvPDfwCPJQ2r3y+Zt3b9mBofd5HVCeb/zedia3gNNga8M+eOe0RZC0B2ax
         oiX5sctyGQG9HREIJ66guf70E7RRpmAt4j55oFgUxrpVAjj2kGv1YxdBp89X8Q0vHCT5
         sQVFNQzEEZJ1/b2O2aki4VMa9b1V9mBFFzt/d7ZOmcwziak2b9T/F4DO8BYpFkU+5tNg
         +08w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=At7aqtjicqewEtGyqeb+vScQZJaX6SY6pPwpi9xbAXE=;
        b=N6GL8lODOFwvhlF8PjbNMcdL0/ZscuQGDT0eYF27D7/rECmEAQLyklACfuNJRwyHJt
         336gbRnoIvEGK/eN4+2jXU2+BUbXxPW+IxM32iqeElJTHTDuqEaAwhKZ3mwWLD5Kw0zR
         a7PyfzKyQo1QoWEa5RDIfAgmbJEFWtL0VX9EhEAftuYdaI2KfcOQcJ//gl1XBSSiODHU
         9e0HVofd7yriLzbRm4P6TFCu76h0sCV7l5YMIN/KtZuTiLD0+F+40l3FzBJvduICcGwq
         QgWx7iHMuVF5gswLbUNW7x0wjGsZXbOjs0YQRsb+g9HdVrFVuMtN9LajJRWgzq+/+uwG
         Ur0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r32si691800qvr.114.2019.02.14.01.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 01:06:39 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1E95j9u062724
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:06:39 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qn55ws3hv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:06:38 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 09:06:37 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 09:06:32 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1E96Vo247382662
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 09:06:31 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8B0DAAE056;
	Thu, 14 Feb 2019 09:06:31 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A92F9AE058;
	Thu, 14 Feb 2019 09:06:30 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 09:06:30 +0000 (GMT)
Date: Thu, 14 Feb 2019 11:06:29 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
        akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
        kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com,
        catalin.marinas@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 1/4] mm: Introduce lazy exec permission setting on a page
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
 <20190213131710.GR12668@bombadil.infradead.org>
 <19b85484-e76b-3ef0-b013-49efa87917ae@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19b85484-e76b-3ef0-b013-49efa87917ae@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021409-0016-0000-0000-000002565487
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021409-0017-0000-0000-000032B08312
Message-Id: <20190214090628.GB9063@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=792 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 07:23:18PM +0530, Anshuman Khandual wrote:
> 
> 
> On 02/13/2019 06:47 PM, Matthew Wilcox wrote:
> > On Wed, Feb 13, 2019 at 01:36:28PM +0530, Anshuman Khandual wrote:
> >> +#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
> >> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
> >> +{
> >> +	if (unlikely(vma->vm_flags & VM_EXEC))
> >> +		return pte_mkexec(entry);
> >> +	return entry;
> >> +}
> >> +#else
> >> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
> >> +{
> >> +	return entry;
> >> +}
> >> +#endif
> > 
> >> +++ b/mm/memory.c
> >> @@ -2218,6 +2218,8 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
> >>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> >>  	entry = pte_mkyoung(vmf->orig_pte);
> >>  	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> >> +	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
> >> +		entry = maybe_mkexec(entry, vma);
> > 
> > I don't understand this bit.  We have a fault based on an instruction
> > fetch.  But we're only going to _maybe_ set the exec bit?  Why not call
> > pte_mkexec() unconditionally?
> 
> Because the arch might not have subscribed to this in which case the fall
> back function does nothing and return the same entry. But in case this is
> enabled it also checks for VMA exec flag (VM_EXEC) before calling into
> pte_mkexec() something similar to existing maybe_mkwrite().

Than why not pass vmf->flags to maybe_mkexec() so that only arches
subscribed to this will have the check for 'flags & FAULT_FLAG_INSTRUCTION' ?

-- 
Sincerely yours,
Mike.

