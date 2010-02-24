Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EA47F6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 11:10:05 -0500 (EST)
Date: Wed, 24 Feb 2010 10:10:03 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
In-Reply-To: <20100224143442.GF3687@quack.suse.cz>
Message-ID: <alpine.DEB.2.00.1002241007220.27592@router.home>
References: <20100224143442.GF3687@quack.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Feb 2010, Jan Kara wrote:

> fine (and you probably don't want much more because the memory is better
> used for something else), when a machine does random rewrites, going to 40%
> might be well worth it. So I'd like to discuss how we could measure that
> increasing amount of dirtiable memory helps so that we could implement
> dynamic sizing of it.

Another issue around dirty limits is that they are global. If you are
running multiple jobs on the same box (memcg or cpusets or you set
affinities to separate the box) then every job may need different dirty
limits. One idea that I had in the past was to set dirty limits based on
nodes or cpusets. But that will not cover the other cases that I have
listed above.

The best solution would be an algorithm that can accomodate multiple loads
and manage the amount of dirty memory automatically.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
