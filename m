Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9F46B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:10:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o7so21333641pgc.23
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 13:10:51 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g68si16140855pgc.304.2017.11.14.13.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 13:10:50 -0800 (PST)
Subject: Re: [PATCH] mm: show total hugetlb memory consumption in
 /proc/meminfo
References: <20171114125026.7055-1-guro@fb.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7b022a49-3bc6-c2cc-2810-e2566ecb0daf@intel.com>
Date: Tue, 14 Nov 2017 13:10:44 -0800
MIME-Version: 1.0
In-Reply-To: <20171114125026.7055-1-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

Do we get an update for Documentation/vm/hugetlbpage.txt to spell out
what our shiny, new and intentionally-ambiguous entry is supposed to
mean and be used for?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
