Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 929916B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 03:20:37 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so30784055pab.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 00:20:37 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ao1si22368736pad.182.2015.01.12.00.20.34
        for <linux-mm@kvack.org>;
        Mon, 12 Jan 2015 00:20:36 -0800 (PST)
Date: Mon, 12 Jan 2015 17:20:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
Message-ID: <20150112082057.GA26078@js1304-P5Q-DELUXE>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
 <54ABA563.1040103@suse.cz>
 <20150108081835.GC25453@js1304-P5Q-DELUXE>
 <54AE43E3.60209@suse.cz>
 <20150109105710.GN2395@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150109105710.GN2395@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 09, 2015 at 10:57:10AM +0000, Mel Gorman wrote:
> On Thu, Jan 08, 2015 at 09:46:27AM +0100, Vlastimil Babka wrote:
> > On 01/08/2015 09:18 AM, Joonsoo Kim wrote:
> > > On Tue, Jan 06, 2015 at 10:05:39AM +0100, Vlastimil Babka wrote:
> > >> On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
> > >> > It'd be useful to know where the both scanner is start. And, it also be
> > >> > useful to know current range where compaction work. It will help to find
> > >> > odd behaviour or problem on compaction.
> > >> 
> > >> Overall it looks good, just two questions:
> > >> 1) Why change the pfn output to hexadecimal with different printf layout and
> > >> change the variable names and? Is it that better to warrant people having to
> > >> potentially modify their scripts parsing the old output?
> > > 
> > > Deciaml output has really bad readability since we manage all pages by order
> > > of 2 which is well represented by hexadecimal. With hex output, we can
> > > easily notice whether we move out from one pageblock to another one.
> > 
> > OK. I don't have any strong objection, maybe Mel should comment on this as the
> > author of most of the tracepoints? But if it happens, I think converting the old
> > tracepoints to new hexadecimal format should be a separate patch from adding the
> > new ones.
> > 
> 
> To date, I'm not aware of any user-space programs that heavily depend on
> the formatting. The scripts I am aware of are ad-hoc and easily modified
> to adapt to format changes. LTT-NG is the only tool that might be
> depending on trace point formats but I severely doubt it's interested in
> this particular tracepoint.

Okay. Thanks for confirmation!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
