Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8CGFjMa029649
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 12:15:45 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8CGNMSh202046
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 10:23:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8CMNLkx009301
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 16:23:21 -0600
Subject: Re: [RFC] [PATCH 8/9] memcg: remove page_cgroup pointer from memmap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1221236354.17910.18.camel@nimitz>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
	 <48CA9500.5060309@linux.vnet.ibm.com>  <1221236354.17910.18.camel@nimitz>
Content-Type: text/plain
Date: Fri, 12 Sep 2008 09:23:13 -0700
Message-Id: <1221236593.17910.21.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-09-12 at 09:19 -0700, Dave Hansen wrote:
> On Fri, 2008-09-12 at 09:12 -0700, Balbir Singh wrote:
> > 3. Integrate with sparsemem (last resort for performance), Dave Hansen suggested
> > adding a mem_section member and using that.
> 
> I also suggested using the sparsemem *structure* without necessarily
> using it for pfn_to_page() lookups.  That'll take some rework to
> separate out SPARSEMEM_FOR_MEMMAP vs. CONFIG_SPARSE_STRUCTURE_FUN, but
> it should be able to be prototyped pretty fast.

Heh, now that I think about it, you could also use vmemmap to do the
same thing.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
