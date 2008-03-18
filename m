Date: Tue, 18 Mar 2008 10:15:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/7] charge/uncharge
Message-Id: <20080318101511.250eeab7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47DDD6E6.8010306@cn.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314190622.0e147b43.kamezawa.hiroyu@jp.fujitsu.com>
	<47DDD6E6.8010306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Mar 2008 11:26:46 +0900
Li Zefan <lizf@cn.fujitsu.com> wrote:

 
> > +	pc = get_page_cgroup(page, gfp_mask, true);
> > +	if (!pc || IS_ERR(pc))
> > +		return PTR_ERR(pc);
> > +
> 
> If get_page_cgroup() returns NULL, you will end up return *sucesss* by
> returning PTR_ERR(pc)
> 
NULL is success. (NULL only returns in boot. I'll add commetns.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
