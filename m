Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4A1696B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 16:21:12 -0500 (EST)
Message-ID: <1330723262.11248.233.camel@twins>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 02 Mar 2012 22:21:02 +0100
In-Reply-To: <20120302112358.GA3481@suse.de>
References: <20120302112358.GA3481@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-03-02 at 11:23 +0000, Mel Gorman wrote:
> For extra style points, the commit introduced the use of yield() in an
> implementation of what looks like a spinning mutex.

Andrew, could you simply say no to any patch adding a yield()? There's a
99% chance its a bug, as was this.=20

This code would life-lock when cpuset_change_task_nodemask() would be
called by the highest priority FIFO task on UP or when pinned to the
same cpu the task doing get_mems_allowed().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
