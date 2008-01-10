Date: Thu, 10 Jan 2008 13:23:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-Id: <20080110132316.4f604724.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080110032631.GE15547@balbir.in.ibm.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080109134132.ba7bb33c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080110022133.GC15547@balbir.in.ibm.com>
	<20080110113618.f967d215.kamezawa.hiroyu@jp.fujitsu.com>
	<20080110032631.GE15547@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008 08:56:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > > The control_type feature is gone. We still have cached page
> > > accounting, but we do not allow control of only RSS pages anymore. We
> > > need to control both RSS+cached pages. I do not understand your
> > > question about new plan? Is it about adding back control_type?
> > > 
> > Ah, just wanted to confirm that we can drop PAGE_CGROUP_FLAG_CACHE
> > if page_file_cache() function and split-LRU is introduced.
> > 
> 
> Earlier we would have had a problem, since we even accounted for swap
> cache with PAGE_CGROUP_FLAG_CACHE and I think page_file_cache() does
> not account swap cache pages with page_file_cache(). Our accounting
> is based on mapped vs unmapped whereas the new code from Rik accounts
> file vs anonymous. I suspect we could live a little while longer
> with PAGE_CGROUP_FLAG_CACHE and then if we do not need it at all,
> we can mark it down for removal. What do you think?

Okay, I have no objection. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
