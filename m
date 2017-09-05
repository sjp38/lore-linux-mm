Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8614428030E
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 03:03:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so3022146wrc.5
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 00:03:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h34si23872wrh.238.2017.09.05.00.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 00:03:55 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v856xQ4l029587
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 03:03:53 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2csnjh4ghj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 03:03:53 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 17:03:50 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v8572WG234406404
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 17:02:32 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v8572WZ4017018
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 17:02:32 +1000
Subject: Re: [PATCH] mm, sparse: fix typo in online_mem_sections
References: <20170904112210.3401-1-mhocko@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 5 Sep 2017 12:32:28 +0530
MIME-Version: 1.0
In-Reply-To: <20170904112210.3401-1-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4d648f70-325d-3f60-8620-94c232b380d8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/04/2017 04:52 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> online_mem_sections accidentally marks online only the first section in
> the given range. This is a typo which hasn't been noticed because I
> haven't tested large 2GB blocks previously. All users of

Section sizes are normally less than 2GB. Could you please elaborate
why this never got noticed before ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
