Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA586B0256
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 11:33:01 -0400 (EDT)
Received: by qkct7 with SMTP id t7so1788652qkc.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 08:33:01 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0031.hostedemail.com. [216.40.44.31])
        by mx.google.com with ESMTP id p28si17428756qkh.92.2015.08.31.08.32.59
        for <linux-mm@kvack.org>;
        Mon, 31 Aug 2015 08:33:00 -0700 (PDT)
Date: Mon, 31 Aug 2015 11:32:57 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/3] mm, compaction: export tracepoints zone names to
 userspace
Message-ID: <20150831113257.54d7ca4b@gandalf.local.home>
In-Reply-To: <1440689044-2922-2-git-send-email-vbabka@suse.cz>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
	<1440689044-2922-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Thu, 27 Aug 2015 17:24:03 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:

> Some compaction tracepoints use zone->name to print which zone is being
> compacted. This works for in-kernel printing, but not userspace trace printing
> of raw captured trace such as via trace-cmd report.
> 
> This patch uses zone_idx() instead of zone->name as the raw value, and when
> printing, converts the zone_type to string using the appropriate EM() macros
> and some ugly tricks to overcome the problem that half the values depend on
> CONFIG_ options and one does not simply use #ifdef inside of #define.
> 
> trace-cmd output before:
> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
> zone=ffffffff81815d7a order=9 ret=partial
> 
> after:
> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
> zone=Normal   order=9 ret=partial
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/trace/events/compaction.h | 38 ++++++++++++++++++++++++++++++++------
>  1 file changed, 32 insertions(+), 6 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
