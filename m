Date: Mon, 11 Dec 2006 11:03:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/16] concurrent pagecache (against 2.6.19-rt)
In-Reply-To: <20061207161800.426936000@chello.nl>
Message-ID: <Pine.LNX.4.64.0612111100300.2253@schroedinger.engr.sgi.com>
References: <20061207161800.426936000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006, Peter Zijlstra wrote:

> Based on Nick's lockless (read-side) pagecache patches (included in the series)
> here an attempt to make the write side concurrent.

On first glance it looks quite interesting and very innovative. Removing 
the tree_lock completely also reduces cache line usage. The page struct 
cacheline is already references in most contexts.

> Comment away ;-)

Could you post Nick's patches from your email addres and add a From Nick 
line in them? Its a bit confusing to have a patchset with different 
originating email addresses. Or does this come about by the evil header 
mangling of the list processor? Maybe you need to use >From ??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
