Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id D6B656B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:25:00 -0500 (EST)
Received: by igvi2 with SMTP id i2so15387992igv.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:25:00 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0181.hostedemail.com. [216.40.44.181])
        by mx.google.com with ESMTP id d5si21244747igx.79.2015.11.12.06.25.00
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 06:25:00 -0800 (PST)
Date: Thu, 12 Nov 2015 09:24:57 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: change trace_mm_vmscan_writepage() proto type
Message-ID: <20151112092457.396c7fc5@gandalf.local.home>
In-Reply-To: <1447314153-10625-1-git-send-email-yalin.wang2010@gmail.com>
References: <1447314153-10625-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: mingo@redhat.com, namhyung@kernel.org, acme@redhat.com, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, bywxiaobai@163.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Nov 2015 15:42:33 +0800
yalin wang <yalin.wang2010@gmail.com> wrote:

> Move trace_reclaim_flags() into trace function,
> so that we don't need caculate these flags if the trace is disabled.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
