Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 301E6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC81021841
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 07:59:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC81021841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92FC06B0006; Wed, 20 Mar 2019 03:59:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B9886B0007; Wed, 20 Mar 2019 03:59:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 735C96B0008; Wed, 20 Mar 2019 03:59:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 49F586B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:59:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k29so20233126qkl.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=nxQVetSAel4IIqTfeLl5dPDrQMsjxBlXJt4R6AxUfe0=;
        b=VgTR9Ltq/hDzrz0ZPaxL0qGRGAG/DnYEZvkHgh/Ll4K1o0xoGt+f3OrIuD9PuQzGsx
         fARofyA9hlydyxH/NqI4pPsXLJj/F06g65IdY1KEbtSjVG2QK/h9Cfw1UynzxlWPoW+B
         YqNPnVs2httQ78VFxsYZSSYeOduQEvJUJcI8DbLaCABB9KG53dM2EoAAP/Jt96XYOhOC
         Q764DiQkllX8SkCAV7pYyI5OwX+SxiK5GUP4hiBLUckXBy4RPZwSSx/dvrokdb+pWIqH
         91BVcwiF+7I5Erbnp8KRLl/PkfTLuYlZNK9CoMijY8nTetFiWZYyo/3+Dl0Iv1l4G3IF
         KvrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVXR0w/3CYG/n2hy/Aoi/EM7nu+/ZBxeuxO49kjN9JQLHAmD5yC
	hiTpkr1BfRFr/hITGjoX9cHNqUAMOFrfMqQ91b18i+oGgx+SGokK+9jkwugkKW4qkypURuXtv5K
	XUAjhEcIv5DyT7Hci4cP9larMvSCKjq7jfQGn/wAEEXlCfjU4FgsCtm6/HBjSGegd0Q==
X-Received: by 2002:aed:3762:: with SMTP id i89mr5126796qtb.311.1553068762088;
        Wed, 20 Mar 2019 00:59:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoh7PB1fvfEVx8pSD9myE+9y/43Me5V85Y+w+uOfL7CTdUl+6A8kcTw9AMmfUSP2UXo1Ai
X-Received: by 2002:aed:3762:: with SMTP id i89mr5126769qtb.311.1553068761447;
        Wed, 20 Mar 2019 00:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553068761; cv=none;
        d=google.com; s=arc-20160816;
        b=0YI4C6U99niltR+lHXyNIfRdzPLVmB323TNI7/lw9ga+roAdH+2qBCL9UoqWdrw998
         fSic6mPC8iyeve4IJw4GJZAY4Oe6Xu4M6aGIdgL5M6rCcj71Tnu2nM1tqRB0vAgyggRB
         uvraCoaapf2fxVGNCzwfOEW/m7HUBGIh8jR1nPl13VPURiFqq8ClPs7BKgeBH0ZI00sL
         ln4zZGSIwtL+Dk7A9e6sdpe871Ii94kC1swH1vckL4dw/9WQaHXc4lULgHg9L+6d6M6W
         DnHgPWQ6cp5QmhqvS6kxrg9oWPqiFtLNsHJzSDskll8iJM2SDqYHHo3MXw7SuRMfMYGr
         rBFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=nxQVetSAel4IIqTfeLl5dPDrQMsjxBlXJt4R6AxUfe0=;
        b=QnQNTPOqeckpbHE/gUrNWXgs7xMUNXSMx1mUME9k7+BDDpGrCGe2CsXvstB8qOvxNF
         nplE3kJJ+72DnsF9UgjYFdDpwsYWZilHp6cCyfUZ5UW5O7QVw/8PPhe9IrFjy1NldUre
         RN1Dzdm5R9kwcA3H5IHzKdXrgXKY21g97Cee+87G7/BCQ2pB4osMIMaWBRrJp1O/i/Pf
         5CHa+/UBgPu4zGaNKyKRc5V9eMvxFixy1Yok9XtMXXdevQ+as3sE0j2jR2ml4BuMPd19
         CAWp5vWn2iTkN6hh/FX2/LfGufxrn0MDIb5aKgxOuZqn3c6xhhk3eI4/rxJKndH5SEl6
         Beyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l3si645125qvc.210.2019.03.20.00.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 00:59:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2K7s9be097859
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:59:20 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rbet9f7s0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:59:19 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 20 Mar 2019 07:59:11 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 20 Mar 2019 07:59:07 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2K7xBqe37683208
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 07:59:11 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CA091A4054;
	Wed, 20 Mar 2019 07:59:11 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 253ABA4060;
	Wed, 20 Mar 2019 07:59:11 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 20 Mar 2019 07:59:11 +0000 (GMT)
Date: Wed, 20 Mar 2019 09:59:09 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, osalvador@suse.de,
        mhocko@suse.com, rppt@linux.vnet.ibm.com, richard.weiyang@gmail.com,
        linux-mm@kvack.org
Subject: Re: [PATCH] mm/sparse: Rename function related to section memmap
 allocation/free
References: <20190320075301.13994-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075301.13994-1-bhe@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032007-4275-0000-0000-0000031D2374
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032007-4276-0000-0000-0000382BA65E
Message-Id: <20190320075908.GD13626@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-20_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903200067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:53:01PM +0800, Baoquan He wrote:
> These functions are used allocate/free section memmap, have nothing
> to do with kmalloc/free during the handling. Rename them to remove
> the confusion.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/sparse.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 054b99f74181..374206212d01 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -579,13 +579,13 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  #endif
> 
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> -static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> +static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
>  		struct vmem_altmap *altmap)
>  {
>  	/* This will make the necessary allocations eventually. */
>  	return sparse_mem_map_populate(pnum, nid, altmap);
>  }
> -static void __kfree_section_memmap(struct page *memmap,
> +static void __free_section_memmap(struct page *memmap,
>  		struct vmem_altmap *altmap)
>  {
>  	unsigned long start = (unsigned long)memmap;
> @@ -603,7 +603,7 @@ static void free_map_bootmem(struct page *memmap)
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  #else
> -static struct page *__kmalloc_section_memmap(void)
> +static struct page *__alloc_section_memmap(void)
>  {
>  	struct page *page, *ret;
>  	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
> @@ -624,13 +624,13 @@ static struct page *__kmalloc_section_memmap(void)
>  	return ret;
>  }
> 
> -static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> +static inline struct page *alloc_section_memmap(unsigned long pnum, int nid,
>  		struct vmem_altmap *altmap)
>  {
> -	return __kmalloc_section_memmap();
> +	return __alloc_section_memmap();
>  }
> 
> -static void __kfree_section_memmap(struct page *memmap,
> +static void __free_section_memmap(struct page *memmap,
>  		struct vmem_altmap *altmap)
>  {
>  	if (is_vmalloc_addr(memmap))
> @@ -701,7 +701,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	usemap = __kmalloc_section_usemap();
>  	if (!usemap)
>  		return -ENOMEM;
> -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> +	memmap = alloc_section_memmap(section_nr, nid, altmap);
>  	if (!memmap) {
>  		kfree(usemap);
>  		return -ENOMEM;
> @@ -726,7 +726,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  out:
>  	if (ret < 0) {
>  		kfree(usemap);
> -		__kfree_section_memmap(memmap, altmap);
> +		__free_section_memmap(memmap, altmap);
>  	}
>  	return ret;
>  }
> @@ -777,7 +777,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap,
>  	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
>  		kfree(usemap);
>  		if (memmap)
> -			__kfree_section_memmap(memmap, altmap);
> +			__free_section_memmap(memmap, altmap);
>  		return;
>  	}
> 
> -- 
> 2.17.2
> 

-- 
Sincerely yours,
Mike.

