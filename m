Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0BADE6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:26:43 -0500 (EST)
Received: by igvi2 with SMTP id i2so15422810igv.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:26:42 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0145.hostedemail.com. [216.40.44.145])
        by mx.google.com with ESMTP id z3si30048527igl.83.2015.11.12.06.26.42
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 06:26:42 -0800 (PST)
Date: Thu, 12 Nov 2015 09:26:39 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: change mm_vmscan_lru_shrink_inactive() proto types
Message-ID: <20151112092639.1011753b@gandalf.local.home>
In-Reply-To: <1447314896-24849-1-git-send-email-yalin.wang2010@gmail.com>
References: <1447314896-24849-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: mingo@redhat.com, namhyung@kernel.org, acme@redhat.com, akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@parallels.com, vbabka@suse.cz, mgorman@techsingularity.net, bywxiaobai@163.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Nov 2015 15:54:56 +0800
yalin wang <yalin.wang2010@gmail.com> wrote:

> Move node_id zone_idx shrink flags into trace function,
> so thay we don't need caculate these args if the trace is disabled,
> and will make this function have less arguments.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
