Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E39CE8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:52:18 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so17783885eda.3
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:52:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si1051851edq.195.2018.12.19.12.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 12:52:17 -0800 (PST)
Date: Wed, 19 Dec 2018 21:52:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 0/6] VA to numa node information
Message-ID: <20181219205215.GC5689@dhcp22.suse.cz>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
 <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
 <20180924171443.GI18685@dhcp22.suse.cz>
 <41af45a9-c428-ccd8-ca10-c355d22c56a7@oracle.com>
 <79d5e991-d9f6-65e2-cb77-0f999fa512fe@oracle.com>
 <c81d912f-157f-749a-92fb-78f5e836da85@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c81d912f-157f-749a-92fb-78f5e836da85@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "prakash.sangappa" <prakash.sangappa@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com

On Tue 18-12-18 15:46:45, prakash.sangappa wrote:
[...]
> Dave Hansen asked how would it scale, with respect reading this file from
> a large process. Answer is, the file contents are generated using page
> table walk, and copied to user buffer. The mmap_sem lock is drop and
> re-acquired in the process of walking the page table and copying file
> content. The kernel buffer size used determines how long the lock is held.
> Which can be further improved to drop the lock and re-acquire after a
> fixed number(512) of pages are walked.

I guess you are still missing the point here. Have you tried a larger
mapping with interleaved memory policy? I would bet my hat that you are
going to spend a large part of the time just pushing the output to the
userspace... Not to mention the parsing on the consumer side.

Also you keep failing (IMO) explaining _who_ is going to be the consumer
of the file. What kind of analysis will need such an optimized data
collection and what can you do about that?

This is really _essential_ when adding a new interface to provide a data
that is already available by other means. In other words tell us your
specific usecase that is hitting a bottleneck that cannot be handled by
the existing API and we can start considering a new one.

-- 
Michal Hocko
SUSE Labs
