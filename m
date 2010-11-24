Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B418C6B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 06:12:58 -0500 (EST)
Message-ID: <4CECF30D.5050204@redhat.com>
Date: Wed, 24 Nov 2010 13:12:13 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/13] IO-less dirty throttling v2
References: <20101117042720.033773013@intel.com>	<20101117150330.139251f9.akpm@linux-foundation.org>	<20101118020640.GS22876@dastard> <20101117180912.38541ca4.akpm@linux-foundation.org>
In-Reply-To: <20101117180912.38541ca4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 11/18/2010 04:09 AM, Andrew Morton wrote:
> But mainly because we're taking the work accounting away from the user
> who caused it and crediting it to the kernel thread instead, and that's
> an actively *bad* thing to do.
>

That's happening more and more with workqueues and kernel threads.

We need the ability for a kernel thread (perhaps a workqueue thread) to 
say "I am doing this on behalf of thread X, please charge any costs I 
incur (faults, cpu time, whatever) to that thread".

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
