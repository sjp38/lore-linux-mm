Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D57626B038F
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:06:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x63so48087837pfx.7
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:06:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p1si10551012pga.393.2017.03.03.05.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 05:06:06 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v23D5a9w061166
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 08:06:06 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xs8e7hd6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 08:05:57 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 18:34:22 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B1CC2125805C
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:34:34 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v23D3EHR7667920
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 18:33:14 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v23D4Kr2015840
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 18:34:21 +0530
Subject: Re: [RFC 11/11] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-12-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 3 Mar 2017 18:34:15 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-12-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <907b98e3-127a-4cad-deea-093785274b64@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> There is no user for it. Remove it.

Last patches in the series prepared ground for this removal. The
entire series looks pretty straight forward. As it does not change
any functionality, wondering what kind of tests this should go
through to look for any potential problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
