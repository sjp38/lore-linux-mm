Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8MGDfhV031913
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 12:13:41 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8MGArJC202502
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 12:10:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8MGAqCG001682
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 12:10:52 -0400
Subject: Re: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove
	pointer from struct page)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <32459434.1222099038142.kamezawa.hiroyu@jp.fujitsu.com>
References: <1222098450.8533.41.camel@nimitz>
	 <1222095177.8533.14.camel@nimitz>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
	 <31600854.1222096483210.kamezawa.hiroyu@jp.fujitsu.com>
	 <32459434.1222099038142.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 09:10:50 -0700
Message-Id: <1222099850.8533.60.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-23 at 00:57 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
> I'll add FLATMEM/SPARSEMEM support later. Could you wait for a while ?
> Because we have lookup_page_cgroup() after this, we can do anything.

OK, I'll stop harassing for the moment, and take a look at the cache. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
