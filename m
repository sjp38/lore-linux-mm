Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3892E6B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:21:45 -0500 (EST)
Received: by ioir85 with SMTP id r85so114226103ioi.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 22:21:45 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id w8si1730331igb.12.2015.11.19.22.21.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 22:21:44 -0800 (PST)
Date: Fri, 20 Nov 2015 15:21:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm/page_isolation: add new tracepoint,
 test_pages_isolated
Message-ID: <20151120062151.GA13061@js1304-P5Q-DELUXE>
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20151119153411.6215be690f75f70b3fa84766@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151119153411.6215be690f75f70b3fa84766@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>

On Thu, Nov 19, 2015 at 03:34:11PM -0800, Andrew Morton wrote:
> On Fri, 13 Nov 2015 11:23:47 +0900 Joonsoo Kim <js1304@gmail.com> wrote:
> 
> > cma allocation should be guranteeded to succeed, but, sometimes,
> > it could be failed in current implementation. To track down
> > the problem, we need to know which page is problematic and
> > this new tracepoint will report it.
> 
> akpm3:/usr/src/25> size mm/page_isolation.o
>    text    data     bss     dec     hex filename
>    2972     112    1096    4180    1054 mm/page_isolation.o-before
>    4608     570    1840    7018    1b6a mm/page_isolation.o-after
> 
> This seems an excessive amount of bloat for one little tracepoint.  Is
> this expected and normal (and acceptable)?

Hello,

I checked bloat on other tracepoints and found that it's normal.
It takes 1KB more per tracepoint.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
