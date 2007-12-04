Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [7/8] bacground reclaim for memory controller
In-Reply-To: Your message of "Tue, 4 Dec 2007 12:18:56 +0900"
	<20071204121856.910afa40.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071204121856.910afa40.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20071204033118.2BA4C1D0B99@siro.lan>
Date: Tue,  4 Dec 2007 12:31:18 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: riel@redhat.com, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> On Tue,  4 Dec 2007 12:07:55 +0900 (JST)
> yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> > you don't need the kthread as far as RES_HWMARK is "infinite".
> > given the current default value of RES_HWMARK, you can simplify
> > initialization by deferring the kthread creation to mem_cgroup_write.
> > 
> Hmm, will try. But I wonder whether assumption can be true forever or not.
> For example, when memory controller supports sub-group and a relationship
> between a parent group and children groups are established.
> 
> But, think it later is an one way ;) I'll try to make things simpler.
> 
> Thanks,
> -Kame

the point is to create a thread when setting RES_HWMARK.
mem_cgroup_write is merely an example.  it can be when inheriting
watermarks from the parent cgroup, etc.
anyway, the assumption we need here is that the default value of
the top level cgroup's high watermark is infinite.  i think it's
a quite reasonable assumption.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
