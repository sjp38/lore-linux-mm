Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 805736B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:26:06 -0400 (EDT)
Date: Tue, 28 Apr 2009 00:26:19 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-ID: <20090428072619.GA29747@eskimo.com>
References: <20090428143019.EBBF.A69D9226@jp.fujitsu.com> <20090428063625.GA17785@eskimo.com> <20090428154835.EBC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428154835.EBC9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 03:52:29PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > 3. cache limitation of memcgroup solve this problem?
> > 
> > I was unable to get this to work -- do you have some documentation handy?
> 
> Do you have kernel source tarball?
> Documentation/cgroups/memory.txt explain usage kindly.

Thank you.  My documentation was out of date.

I created a cgroup with limited memory and placed a copy command in it, and the
latency problem seems to essentially go away.  However, I'm also a bit
suspicious that my test might have become invalid, since my IO performance
seems to have dropped somewhat too.

So, am I right in concluding that this more or less implicates bad page
replacement as the culprit?  After I dropped vm caches and let my working set
re-form, the memory cgroup seems to be effective at keeping a large pool of
memory free from file pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
