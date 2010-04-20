Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A32F86B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 11:05:44 -0400 (EDT)
Date: Tue, 20 Apr 2010 16:05:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
Message-ID: <20100420150522.GG19264@csn.ul.ie>
References: <4BC6CB30.7030308@kernel.org> <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com> <4BC6E581.1000604@kernel.org> <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com> <4BC6FBC8.9090204@kernel.org> <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com> <alpine.DEB.2.00.1004161105120.7710@router.home> <1271606079.2100.159.camel@barrios-desktop> <alpine.DEB.2.00.1004191235160.9855@router.home> <4BCCD8BD.1020307@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BCCD8BD.1020307@kernel.org>
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 07:27:09AM +0900, Tejun Heo wrote:
> Hello, Christoph.
> 
> On 04/20/2010 02:38 AM, Christoph Lameter wrote:
> > alloc_pages_exact_node results in more confusion because it does suggest
> > that fallback to other nodes is not allowed.
> 
> I can't see why alloc_pages_exact_node() exists at all.  It's in the
> mainline and if you look at the difference between alloc_pages_node()
> and alloc_pages_exact_node(), it's almost silly.  :-(
> 

alloc_pages_exact_node() avoids a branch in a hot path that is checking for
something the caller already knows. That's the reason it exists.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
