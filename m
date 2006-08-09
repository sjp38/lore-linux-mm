Date: Wed, 9 Aug 2006 10:34:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
Message-Id: <20060809103433.99f14cb7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006 09:33:46 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Add a new gfp flag __GFP_THISNODE to avoid fallback to other nodes. This flag
> is essential if a kernel component requires memory to be located on a
> certain node. It will be needed for alloc_pages_node() to force allocation
> on the indicated node and for alloc_pages() to force allocation on the
> current node.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

Hm, passing a nodemask as argment to alloc_page_???()is too more complicated
than GFP_THISNODE ? (it will increase # of args but...)

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
