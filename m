Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B14E96B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:32:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c20so117000378pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 01:32:40 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id wj2si6520667pab.71.2016.04.14.01.32.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 01:32:39 -0700 (PDT)
Subject: Re: [PATCH v2] cpuset: use static key better and convert to new API
References: <1459931973-29247-1-git-send-email-vbabka@suse.cz>
 <1459934392-12756-1-git-send-email-vbabka@suse.cz>
From: Zefan Li <lizefan@huawei.com>
Message-ID: <570F54C2.2000300@huawei.com>
Date: Thu, 14 Apr 2016 16:28:50 +0800
MIME-Version: 1.0
In-Reply-To: <1459934392-12756-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/4/6 17:19, Vlastimil Babka wrote:
> An important function for cpusets is cpuset_node_allowed(), which optimizes on
> the fact if there's a single root CPU set, it must be trivially allowed. But
> the check "nr_cpusets() <= 1" doesn't use the cpusets_enabled_key static key
> the right way where static keys eliminate branching overhead with jump labels.
> 
> This patch converts it so that static key is used properly. It's also switched
> to the new static key API and the checking functions are converted to return
> bool instead of int. We also provide a new variant __cpuset_zone_allowed()
> which expects that the static key check was already done and they key was
> enabled. This is needed for get_page_from_freelist() where we want to also
> avoid the relatively slower check when ALLOC_CPUSET is not set in alloc_flags.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Looks good to me.

Acked-by: Zefan Li <lizefan@huawei.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
