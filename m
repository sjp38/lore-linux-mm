Date: Tue, 18 Mar 2008 10:14:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] charge/uncharge
Message-Id: <20080318101404.76ec357a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080317014601.GB24473@balbir.in.ibm.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314190622.0e147b43.kamezawa.hiroyu@jp.fujitsu.com>
	<20080317014601.GB24473@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 07:16:01 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:06:22]:
> 
> > Because bit spin lock is removed and spinlock is added to page_cgroup.
> > There are some amount of changes.
> > 
> > This patch does
> > 	- modify charge/uncharge to adjust it to the new lock.
> > 	- Added simple lock rule comments.
> > 
> > Major changes from current(-mm) version is
> > 	- pc->refcnt is set as "1" after the charge is done.
> > 
> > Changelog
> >   - Rebased to rc5-mm1
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> 
> Hi, KAMEZAWA-San,
> 
> The build continues to be broken, even after this patch is applied.
> We will have to find another way to refactor the code, so that we
> don't break git-bisect.
>  
At least, patch 1-5 should be applied.
Hmm, ok. folding patch 1-5 to one patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
