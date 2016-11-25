Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49EB46B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 19:06:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q10so136589439pgq.7
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 16:06:51 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id n190si41470824pgn.27.2016.11.24.16.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 16:06:50 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id e9so4290765pgc.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 16:06:50 -0800 (PST)
Subject: Re: [PATCH 2/5] mm: migrate: Change migrate_mode to support
 combination migration modes.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-3-zi.yan@sent.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <6246a5ee-a1e1-3819-3ad0-3adc25db76f0@gmail.com>
Date: Fri, 25 Nov 2016 11:06:43 +1100
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-3-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>



On 23/11/16 03:25, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>
> 
> No functionality is changed.


I think you'd want to say that the modes are no longer
exclusive. We can use them as flags in combination?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
