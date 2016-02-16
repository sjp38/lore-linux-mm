Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 706476B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 20:16:07 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id y8so66392711igp.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 17:16:07 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0102.hostedemail.com. [216.40.44.102])
        by mx.google.com with ESMTPS id ug8si30746614igb.89.2016.02.15.17.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 17:16:06 -0800 (PST)
Date: Mon, 15 Feb 2016 20:16:02 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160215201602.350d73fa@gandalf.local.home>
In-Reply-To: <20160216004720.GA1782@js1304-P5Q-DELUXE>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160215110741.7c0c5039@gandalf.local.home>
	<20160216004720.GA1782@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue, 16 Feb 2016 09:47:20 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > They return true when CONFIG_TRACEPOINTS is configured in and the
> > tracepoint is enabled, and false otherwise.  
> 
> This implementation is what you proposed before. Please refer below
> link and source.
> 
> https://lkml.org/lkml/2015/12/9/699
> arch/x86/include/asm/msr.h

That was a year ago, how am I suppose to remember ;-)

> 
> There is header file dependency problem between mm.h and tracepoint.h.
> page_ref.h should be included in mm.h and tracepoint.h cannot
> be included in this case.

Ah, OK, I forgot about that. I'll take another look at it again.

A lot happened since then, that's all a fog to me.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
