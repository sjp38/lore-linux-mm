Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3B86B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:16:43 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id y42so10217075qtc.19
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 21:16:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p90si1426900qtd.50.2018.01.29.21.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 21:16:42 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0U5FJPA025176
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:16:41 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fte240kuj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:16:41 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 05:16:39 -0000
Subject: Re: [RFC] mm/migrate: Add new migration reason MR_HUGETLB
References: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 30 Jan 2018 10:46:32 +0530
MIME-Version: 1.0
In-Reply-To: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <7c99fbcd-bb9f-38ed-fbf1-e5481c59968c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com

On 01/30/2018 08:37 AM, Anshuman Khandual wrote:
> @@ -7621,8 +7622,13 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>  							&cc->migratepages);
>  		cc->nr_migratepages -= nr_reclaimed;
>  
> +		if (migratetype == MIGRATE_CMA)
> +			migrate_reason = MR_CMA;
> +		else
> +			migrate_reason = MR_HUGETLB;
> +
>  		ret = migrate_pages(&cc->migratepages, new_page_alloc_contig,

Oops, this is on top of the changes from the other RFC regarding migration
helper functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
