Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB5C16B0395
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 11:02:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id o126so9739007pfb.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 08:02:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z13si422203pfj.93.2017.03.07.08.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 08:02:21 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v27FrvQd050455
	for <linux-mm@kvack.org>; Tue, 7 Mar 2017 11:02:21 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 291xwpv0e8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Mar 2017 11:02:21 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Mar 2017 02:02:18 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v27G29EP43581472
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 03:02:17 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v27G1iND030023
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 03:01:44 +1100
Subject: Re: [PATCH] mm: Do not use double negation for testing page flags
References: <1488868597-32222-1-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 7 Mar 2017 21:31:18 +0530
MIME-Version: 1.0
In-Reply-To: <1488868597-32222-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <8b5c4679-484e-fe7f-844b-af5fd41b01e0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Vlastimil Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 03/07/2017 12:06 PM, Minchan Kim wrote:
> With the discussion[1], I found it seems there are every PageFlags
> functions return bool at this moment so we don't need double
> negation any more.
> Although it's not a problem to keep it, it makes future users
> confused to use dobule negation for them, too.
> 
> Remove such possibility.

A quick search of '!!Page' in the source tree does not show any other
place having this double negation. So I guess this is all which need
to be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
