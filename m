Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23B0A6B0007
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:25:15 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k11so12606791qth.23
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:25:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a6si86155qth.186.2018.01.30.18.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 18:25:14 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0V2P3wu125813
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:25:13 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fu2yvky0t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:25:13 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 31 Jan 2018 02:25:10 -0000
Subject: Re: [RFC] mm/migrate: Add new migration reason MR_HUGETLB
References: <20180130030714.6790-1-khandual@linux.vnet.ibm.com>
 <20180130075949.GN21609@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 31 Jan 2018 07:55:05 +0530
MIME-Version: 1.0
In-Reply-To: <20180130075949.GN21609@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <b4bd6cda-a3b7-96dd-b634-d9b3670c1ecf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 01/30/2018 01:29 PM, Michal Hocko wrote:
> On Tue 30-01-18 08:37:14, Anshuman Khandual wrote:
>> alloc_contig_range() initiates compaction and eventual migration for
>> the purpose of either CMA or HugeTLB allocation. At present, reason
>> code remains the same MR_CMA for either of those cases. Lets add a
>> new reason code which will differentiate the purpose of migration
>> as HugeTLB allocation instead.
> Why do we need it?

The same reason why we have MR_CMA (maybe some other ones as well) at
present, for reporting purpose through traces at the least. It just
seemed like same reason code is being used for two different purpose
of migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
