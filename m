Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 6BE6D6B13F2
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:03:22 -0500 (EST)
Message-ID: <4F294626.4020207@redhat.com>
Date: Wed, 01 Feb 2012 09:03:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] [ATTEND] mm track: RAM utilization and page replacement
 topics
References: <f6fc422f-fbc2-4a19-b723-82c23f6aa3fe@default>
In-Reply-To: <f6fc422f-fbc2-4a19-b723-82c23f6aa3fe@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 01/27/2012 12:19 PM, Dan Magenheimer wrote:
> Some (related) topics proposed for the MM track:
>
> 1) Optimizing the utilization of RAM as a resource, i.e. how do we teach the
>     kernel to NOT use all RAM when it doesn't really "need" it.  See
>     http://lwn.net/Articles/475681/ (or if you don't want to read the whole
>     article, start with "Interestingly, ..." four paragraphs from the end).
>
> 2) RAMster now exists and works... where are the holes and what next?
>     http://marc.info/?l=linux-mm&m=132768187222840&w=2
>
> 3) Next steps in the page replacement algorithm:
> 	a) WasActive https://lkml.org/lkml/2012/1/25/300
> 	b) readahead http://marc.info/?l=linux-scsi&m=132750980203130
>
> 4) Remaining impediments for merging frontswap
>
> 5) Page flags and 64-bit-only... what are the tradeoffs?

I am interested in these topics.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
