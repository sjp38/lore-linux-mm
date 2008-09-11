From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] [PATCH 8/9] memcg: remove page_cgroup pointer from memmap
Date: Fri, 12 Sep 2008 00:00:37 +1000
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com> <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809120000.37901.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

On Thursday 11 September 2008 21:22, KAMEZAWA Hiroyuki wrote:
> Remove page_cgroup pointer from struct page.
>
> This patch removes page_cgroup pointer from struct page and make it be able
> to get from pfn. Then, relationship of them is
>
> Before this:
>   pfn <-> struct page <-> struct page_cgroup.
> After this:
>   struct page <-> pfn -> struct page_cgroup -> struct page.

So...

pfn -> *hash* -> struct page_cgroup, right?

While I don't think there is anything wrong with the approach, I
don't understand exactly where you guys are hoping to end up with
this?

I thought everyone was happy with preallocated page_cgroups because
of their good performance and simplicity, but this seems to be
going the other way again.

I'd worry that the hash and lookaside buffers and everything makes
performance more fragile, adds code and data and icache to fastpaths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
