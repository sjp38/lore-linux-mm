Date: Thu, 10 Jan 2008 11:36:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-Id: <20080110113618.f967d215.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080110022133.GC15547@balbir.in.ibm.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080109134132.ba7bb33c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080110022133.GC15547@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008 07:51:33 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > >  #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
> > >  #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
> > > +#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
> > > 
> > 
> > Now, we don't have control_type and a feature for accounting only CACHE.
> > Balbir-san, do you have some new plan ?
> >
> 
> Hi, KAMEZAWA-San,
> 
> The control_type feature is gone. We still have cached page
> accounting, but we do not allow control of only RSS pages anymore. We
> need to control both RSS+cached pages. I do not understand your
> question about new plan? Is it about adding back control_type?
> 
Ah, just wanted to confirm that we can drop PAGE_CGROUP_FLAG_CACHE
if page_file_cache() function and split-LRU is introduced.


Thanks you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
