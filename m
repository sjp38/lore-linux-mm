From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Date: Tue, 9 Sep 2008 22:28:18 +1000
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <48C66AF8.5070505@linux.vnet.ibm.com>
In-Reply-To: <48C66AF8.5070505@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809092228.18680.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 09 September 2008 22:24, Balbir Singh wrote:
> KAMEZAWA Hiroyuki wrote:

> > Balbir, are you ok to CONFIG_CGROUP_MEM_RES_CTLR depends on
> > CONFIG_SPARSEMEM ? I thinks SPARSEMEM(SPARSEMEM_VMEMMAP) is widely used
> > in various archs now.
>
> Can't we make it more generic. I was thinking of allocating memory for each
> node for page_cgroups (of the size of spanned_pages) at initialization
> time. I've not yet prototyped the idea. BTW, even with your approach I fail
> to see why we need to add a dependency on CONFIG_SPARSEMEM (but again it is
> 4:30 in the morning and I might be missing the obvious)

I guess it would be just a matter of coding up the implementation for
each model you want to support. In some cases, you might lose memory
(eg in the case of flatmem where you have holes in ram), but in those
cases you lose memory from the struct pages anyway so I wouldn't worry
too much.

I think it would be reasonable to provide an implementation for flatmem
as well (which AFAIK is the other non-deprecated memory model). It
should not be hard to code AFAIKS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
