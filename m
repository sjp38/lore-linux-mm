Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A47D6B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:24:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j124so8601766ith.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 08:24:15 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0214.hostedemail.com. [216.40.44.214])
        by mx.google.com with ESMTPS id g17si20583027ita.7.2016.07.27.08.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 08:24:15 -0700 (PDT)
Date: Wed, 27 Jul 2016 11:24:11 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm: compaction.c: Add/Modify direct compaction
 tracepoints
Message-ID: <20160727112411.6e60c186@gandalf.local.home>
In-Reply-To: <7d2c2beef96e76cb01a21eee85ba5611bceb4307.1469629027.git.janani.rvchndrn@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	<7d2c2beef96e76cb01a21eee85ba5611bceb4307.1469629027.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Wed, 27 Jul 2016 10:51:03 -0400
Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:

> Add zone information to an existing tracepoint in compact_zone(). Also,
> add a new tracepoint at the end of the compaction code so that latency 
> information can be derived.
> 
> Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
> ---

>  
> +	trace_mm_compaction_try_to_compact_pages_end(rc, *contended);
> +

Again, I'm not to thrilled about tracepoints just being added to track
the length of function calls. We have function graph tracer for that.

-- Steve


>  	return rc;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
