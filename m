Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D9BFC6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 07:34:47 -0500 (EST)
Date: Wed, 16 Dec 2009 20:33:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: introduce dump_page() and print symbolic flag names
Message-ID: <20091216123310.GA17522@localhost>
References: <20091216122640.GA13817@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091216122640.GA13817@localhost>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 16, 2009 at 08:26:40PM +0800, Wu Fengguang wrote:
> - introduce dump_page() to print the page info for debugging some error condition.
> - convert three mm users: bad_page(), print_bad_pte() and memory offline failure. 
> - print an extra field: the symbolic names of page->flags
> 
> Example dump_page() output:
> 
> [  157.521694] page:ffffea0000a7cba8 count:2 mapcount:1
> mapping:ffff88001c901791 index:147
                                 ~~~ this is in fact 0x147

The index value may sometimes be misread as decimal number, shall this
be fixed by adding a "0x" prefix?

> [  157.525570] page flags: 100000000100068(uptodate|lru|active|swapbacked)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
