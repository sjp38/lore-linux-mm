Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id C8AC46B0256
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:55:44 -0400 (EDT)
Received: by igboj15 with SMTP id oj15so28695903igb.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:55:44 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0133.hostedemail.com. [216.40.44.133])
        by mx.google.com with ESMTP id i188si11977889ioi.194.2015.08.31.07.55.43
        for <linux-mm@kvack.org>;
        Mon, 31 Aug 2015 07:55:43 -0700 (PDT)
Date: Mon, 31 Aug 2015 10:55:38 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/3] mm, compaction: export tracepoints status strings
 to userspace
Message-ID: <20150831105538.2cf4b3ae@gandalf.local.home>
In-Reply-To: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Thu, 27 Aug 2015 17:24:02 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:

> Some compaction tracepoints convert the integer return values to strings using
> the compaction_status_string array. This works for in-kernel printing, but not
> userspace trace printing of raw captured trace such as via trace-cmd report.
> 
> This patch converts the private array to appropriate tracepoint macros that
> result in proper userspace support.
> 
> trace-cmd output before:
> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
>   zone=ffffffff81815d7a order=9 ret=
> 
> after:
> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
>   zone=ffffffff81815d7a order=9 ret=partial
> 

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/trace/events/compaction.h | 33 +++++++++++++++++++++++++++++++--
>  mm/compaction.c                   | 11 -----------
>  2 files changed, 31 insertions(+), 13 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
