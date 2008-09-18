Date: Thu, 18 Sep 2008 14:15:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page (v3)
Message-Id: <20080918141540.5e50f1b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48D1DFE0.5010208@linux.vnet.ibm.com>
References: <200809091500.10619.nickpiggin@yahoo.com.au>
	<20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
	<30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
	<20080910012048.GA32752@balbir.in.ibm.com>
	<1221085260.6781.69.camel@nimitz>
	<48C84C0A.30902@linux.vnet.ibm.com>
	<1221087408.6781.73.camel@nimitz>
	<20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com>
	<48C878AD.4040404@linux.vnet.ibm.com>
	<20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917232826.GA19256@balbir.in.ibm.com>
	<20080917184008.92b7fc4c.akpm@linux-foundation.org>
	<20080918134304.93985542.kamezawa.hiroyu@jp.fujitsu.com>
	<48D1DFE0.5010208@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2008 21:58:08 -0700
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:

> > BTW, I already have lazy-lru-by-pagevec protocol on my patch(hash version) and
> > seems to work well. I'm now testing it and will post today if I'm enough lucky.
> 
> cool! Please do post what numbers you see as well. I would appreciate if you can
> try this version and see what sort of performance issues you see.
> 
I'll see what happens. your patch is agasint rc6-mmtom ?

BTW, my 8cpu/2socket/Xeon 3.16GHz host is back now. Maybe good for seeing performance.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
