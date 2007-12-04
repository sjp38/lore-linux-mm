Date: Tue, 4 Dec 2007 12:18:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [7/8] bacground reclaim for memory controller
Message-Id: <20071204121856.910afa40.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071204030756.25A971D0B8F@siro.lan>
References: <20071203184244.200faee8.kamezawa.hiroyu@jp.fujitsu.com>
	<20071204030756.25A971D0B8F@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: riel@redhat.com, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue,  4 Dec 2007 12:07:55 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> you don't need the kthread as far as RES_HWMARK is "infinite".
> given the current default value of RES_HWMARK, you can simplify
> initialization by deferring the kthread creation to mem_cgroup_write.
> 
Hmm, will try. But I wonder whether assumption can be true forever or not.
For example, when memory controller supports sub-group and a relationship
between a parent group and children groups are established.

But, think it later is an one way ;) I'll try to make things simpler.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
