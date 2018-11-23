Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA70C6B319B
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:49:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so6037376eda.3
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:49:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si4199018edd.122.2018.11.23.07.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 07:49:05 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d07d9742-e7dc-0fe7-c4be-3bd9a60fde98@suse.cz>
Date: Fri, 23 Nov 2018 16:49:04 +0100
MIME-Version: 1.0
In-Reply-To: <20181120103515.25280-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/20/18 11:35 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> David Rientjes has reported that 1860033237d4 ("mm: make
> PR_SET_THP_DISABLE immediately active") has changed the way how
> we report THPable VMAs to the userspace. Their monitoring tool is
> triggering false alarms on PR_SET_THP_DISABLE tasks because it considers
> an insufficient THP usage as a memory fragmentation resp. memory
> pressure issue.
> 
> Before the said commit each newly created VMA inherited VM_NOHUGEPAGE
> flag and that got exposed to the userspace via /proc/<pid>/smaps file.
> This implementation had its downsides as explained in the commit message
> but it is true that the userspace doesn't have any means to query for
> the process wide THP enabled/disabled status.
> 
> PR_SET_THP_DISABLE is a process wide flag so it makes a lot of sense
> to export in the process wide context rather than per-vma. Introduce

Agreed.

> a new field to /proc/<pid>/status which export this status.  If
> PR_SET_THP_DISABLE is used then it reports false same as when the THP is
> not compiled in. It doesn't consider the global THP status because we
> already export that information via sysfs
> 
> Fixes: 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
