Date: Tue, 18 Mar 2008 10:12:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] re-define page_cgroup.
Message-Id: <20080318101243.18a7c694.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47DDB9A5.1000405@cn.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
	<47DDB9A5.1000405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 09:21:57 +0900
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > (This is one of a series of patch for "lookup page_cgroup" patches..)
> > 
> >  * Exporting page_cgroup definition.
> >  * Remove page_cgroup member from sturct page.
> >  * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.
> > 
> > Other chages will appear in following patches.
> > There is a change in the structure itself, spin_lock is added.
> > 
> > Changelog:
> >  - adjusted to rc5-mm1
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Please don't break git-bisect. Make sure your patches can be applied one
> by one.
> 
folding all 7 patches into one patch ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
