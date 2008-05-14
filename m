Date: Wed, 14 May 2008 17:32:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC/PATCH 4/6] memcg: shmem reclaim helper
Message-Id: <20080514173209.860d1c1d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <482AA16D.7060200@cn.fujitsu.com>
References: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20080514171025.2f0fb1ca.kamezawa.hiroyu@jp.fujitsu.com>
	<482A9FB5.4020202@cn.fujitsu.com>
	<20080514172531.672e0447.kamezawa.hiroyu@jp.fujitsu.com>
	<482AA16D.7060200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 May 2008 16:23:09 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 14 May 2008 16:15:49 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> >>> +	while(!progress && --retry) {
> >>> +		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
> >>> +	}
> >> This is wrong. How about:
> >> 	do {
> >> 		...
> >> 	} while (!progress && --retry);
> >>
> > Ouch, or retry--....
> > 
> 
> retry-- is still wrong, because then after while, retry will be -1, and then:
> 
> +	if (!retry)
> +		return -ENOMEM;
> 
ok, i'm now rewriting.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
