Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5E040830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:46:06 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id l127so94136935iof.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:46:06 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.228])
        by mx.google.com with ESMTP id a138si17280403ioe.160.2016.02.18.17.46.05
        for <linux-mm@kvack.org>;
        Thu, 18 Feb 2016 17:46:05 -0800 (PST)
Date: Thu, 18 Feb 2016 20:46:02 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160218204602.1d771714@grimm.local.home>
In-Reply-To: <CAAmzW4Ni2uZ_J1dcfHPNPYDc0EDDDOL+_oKD-+OZ=Cmg=8sgGA@mail.gmail.com>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160218092926.083ca007@gandalf.local.home>
	<20160219003421.GA587@swordfish>
	<CAAmzW4Ni2uZ_J1dcfHPNPYDc0EDDDOL+_oKD-+OZ=Cmg=8sgGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 19 Feb 2016 10:39:10 +0900
Joonsoo Kim <js1304@gmail.com> wrote:


> > not sure if it's worth mentioning in the comment, but the other
> > concern here is the performance impact of an extra function call,
> > I believe. otherwise, Joonsoo would just do:  
> 
> It's very natural thing so I'm not sure it is worth mentioning.
> 

Agreed.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
