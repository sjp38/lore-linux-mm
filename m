Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 88B8C6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:11:14 -0400 (EDT)
Date: Tue, 26 Jun 2012 22:12:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: needed lru_add_drain_all() change
Message-Id: <20120626221217.1682572a.akpm@linux-foundation.org>
In-Reply-To: <4FEA6B5B.5000205@kernel.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
	<4FEA59EE.8060804@kernel.org>
	<20120626181504.23b8b73d.akpm@linux-foundation.org>
	<4FEA6B5B.5000205@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Wed, 27 Jun 2012 11:09:31 +0900 Minchan Kim <minchan@kernel.org> wrote:

> On 06/27/2012 10:15 AM, Andrew Morton wrote:
> 
> >> Considering mlock and CPU pinning
> >> > of realtime thread is very rare, it might be rather expensive solution.
> >> > Unfortunately, I have no idea better than you suggested. :(
> >> > 
> >> > And looking 8891d6da17, mlock's lru_add_drain_all isn't must.
> >> > If it's really bother us, couldn't we remove it?
> > "grep lru_add_drain_all mm/*.c".  They're all problematic.
> 
> 
> Yeb but I'm not sure such system modeling is good.
> Potentially, It could make problem once we use workqueue of other CPU.

whut?

My suggestion is that we switch lru_add_drain_all() to on_each_cpu()
and delete schedule_on_each_cpu().  No workqueues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
