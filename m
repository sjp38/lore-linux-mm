Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id D77E782F77
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 22:36:52 -0500 (EST)
Received: by ioc74 with SMTP id 74so81934962ioc.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 19:36:52 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id l10si11254603igu.15.2015.12.09.19.36.52
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 19:36:52 -0800 (PST)
Date: Wed, 9 Dec 2015 22:36:48 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151209223648.4e9122b5@grimm.local.home>
In-Reply-To: <20151210025015.GA17967@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
	<564C9A86.1090906@suse.cz>
	<20151120063325.GB13061@js1304-P5Q-DELUXE>
	<20151120114225.7efeeafe@grimm.local.home>
	<20151123082805.GB29397@js1304-P5Q-DELUXE>
	<20151123092604.7ec1397d@gandalf.local.home>
	<20151124014527.GA32335@js1304-P5Q-DELUXE>
	<20151203041657.GB1495@js1304-P5Q-DELUXE>
	<20151209150154.31c142b9@gandalf.local.home>
	<20151210025015.GA17967@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, 10 Dec 2015 11:50:15 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Output of cpu 3, 7 are mixed and it's not easy to analyze it.
> 
> I think that it'd be better not to sort stack trace. How do
> you think about it? Could you fix it, please?

It may not be that easy to fix because of the sorting algorithm. That
would require looking going ahead one more event each time and then
checking if its a stacktrace. I may look at it and see if I can come up
with something that's not too invasive in the algorithms.

That said, for now you can use the --cpu option. I'm not sure I ever
documented it as it was originally added for debugging, but I use it
enough that it may be worth while to officially support it.

 trace-cmd report --cpu 3

Will show you just cpu 3 and nothing else. Which is what I use a lot.

But doing the stack trace thing may be something to fix as well. I'll
see what I can do, but no guarantees.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
