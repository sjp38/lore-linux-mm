Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAA73v3j022720
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Nov 2008 16:03:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3920045DD7B
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:03:57 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BD545DD7A
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:03:57 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id EEF69E08001
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:03:56 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id ACBBC1DB803A
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:03:56 +0900 (JST)
Date: Mon, 10 Nov 2008 16:03:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/6] memcg: mem+swap controller
Message-Id: <20081110160321.3ec35dd3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081110133054.b090816c.nishimura@mxp.nes.nec.co.jp>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<20081105172316.354c00fb.kamezawa.hiroyu@jp.fujitsu.com>
	<20081110133054.b090816c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Nov 2008 13:30:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -1062,13 +1208,55 @@ int mem_cgroup_resize_limit(struct mem_c
> >  			break;
> >  		}
> >  		progress = try_to_free_mem_cgroup_pages(memcg,
> > -				GFP_HIGHUSER_MOVABLE);
> > +				GFP_HIGHUSER_MOVABLE, false);
> >  		if (!progress)
> >  			retry_count--;
> >  	}
> >  	return ret;
> >  }
> >  
> mem_cgroup_resize_limit() should verify that mem.limit <= memsw.limit
> as mem_cgroup_resize_memsw_limit() does.
> 
> 
nice catch. will be fixed in the next version.

Thanks a lot!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
