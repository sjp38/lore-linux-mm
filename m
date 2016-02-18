Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id CF59A828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:20:59 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id g6so14635971igt.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 06:20:59 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0183.hostedemail.com. [216.40.44.183])
        by mx.google.com with ESMTPS id rp3si5580023igb.67.2016.02.18.06.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 06:20:59 -0800 (PST)
Date: Thu, 18 Feb 2016 09:20:56 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160218092056.18a5af4a@gandalf.local.home>
In-Reply-To: <CAAmzW4M3efu7T-PGtBwN=uNZ+bYpWCX+DBQK_nS149O9yyUu0w@mail.gmail.com>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160215110741.7c0c5039@gandalf.local.home>
	<20160216004720.GA1782@js1304-P5Q-DELUXE>
	<20160215201602.350d73fa@gandalf.local.home>
	<CAAmzW4M3efu7T-PGtBwN=uNZ+bYpWCX+DBQK_nS149O9yyUu0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Thu, 18 Feb 2016 16:46:08 +0900
Joonsoo Kim <js1304@gmail.com> wrote:

> 2016-02-16 10:16 GMT+09:00 Steven Rostedt <rostedt@goodmis.org>:
> > On Tue, 16 Feb 2016 09:47:20 +0900
> > Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >  
> >> > They return true when CONFIG_TRACEPOINTS is configured in and the
> >> > tracepoint is enabled, and false otherwise.  
> >>
> >> This implementation is what you proposed before. Please refer below
> >> link and source.
> >>
> >> https://lkml.org/lkml/2015/12/9/699
> >> arch/x86/include/asm/msr.h  
> >
> > That was a year ago, how am I suppose to remember ;-)  
> 
> I think you are smart enough to remember. :)
> I will add it on commit description on next spin.
> 
>

Better yet, add it to the code. I'll reply to the patch.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
