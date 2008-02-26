Date: Tue, 26 Feb 2008 18:07:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [1/7] definitions
 for page_cgroup
Message-Id: <20080226180744.81625f75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080226.164641.117922308.taka@valinux.co.jp>
References: <20080225121034.bd74be07.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225.164745.47821156.taka@valinux.co.jp>
	<20080225170352.2415dc58.kamezawa.hiroyu@jp.fujitsu.com>
	<20080226.164641.117922308.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008 16:46:41 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

>
> > > (3) The page member can be replaced with the page frame number and it will be
> > >     also possible to use some kind of ID instead of the mem_cgroup member.
> > >     This means these members can be encoded to one members with other members
> > >     such as "flags" and "refcnt"
> >  
> > I think there is a case that "pfn" doesn't fit in 32bit.
> > (64bit system tend to have sparse address space.)
> > We need unsigned long anyway.
> 
> It will be a 64bit variable on a 64bit machine, where the pointers are
> also 64bit long. I think you can encode "pfn" and other stuff into one
> 64bit variable.
> 
Next version will have reclaim of page_cgroup, I'm now trying.
The size itself will be discussed later.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
