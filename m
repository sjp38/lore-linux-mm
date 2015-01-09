Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id D5FF96B0038
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 05:57:15 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id q58so7302818wes.12
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 02:57:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj7si46574760wib.43.2015.01.09.02.57.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 02:57:15 -0800 (PST)
Date: Fri, 9 Jan 2015 10:57:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
Message-ID: <20150109105710.GN2395@suse.de>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
 <54ABA563.1040103@suse.cz>
 <20150108081835.GC25453@js1304-P5Q-DELUXE>
 <54AE43E3.60209@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <54AE43E3.60209@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 08, 2015 at 09:46:27AM +0100, Vlastimil Babka wrote:
> On 01/08/2015 09:18 AM, Joonsoo Kim wrote:
> > On Tue, Jan 06, 2015 at 10:05:39AM +0100, Vlastimil Babka wrote:
> >> On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
> >> > It'd be useful to know where the both scanner is start. And, it also be
> >> > useful to know current range where compaction work. It will help to find
> >> > odd behaviour or problem on compaction.
> >> 
> >> Overall it looks good, just two questions:
> >> 1) Why change the pfn output to hexadecimal with different printf layout and
> >> change the variable names and? Is it that better to warrant people having to
> >> potentially modify their scripts parsing the old output?
> > 
> > Deciaml output has really bad readability since we manage all pages by order
> > of 2 which is well represented by hexadecimal. With hex output, we can
> > easily notice whether we move out from one pageblock to another one.
> 
> OK. I don't have any strong objection, maybe Mel should comment on this as the
> author of most of the tracepoints? But if it happens, I think converting the old
> tracepoints to new hexadecimal format should be a separate patch from adding the
> new ones.
> 

To date, I'm not aware of any user-space programs that heavily depend on
the formatting. The scripts I am aware of are ad-hoc and easily modified
to adapt to format changes. LTT-NG is the only tool that might be
depending on trace point formats but I severely doubt it's interested in
this particular tracepoint.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
