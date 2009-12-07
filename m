Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED846B0044
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 00:38:28 -0500 (EST)
Date: Mon, 7 Dec 2009 06:38:06 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC] print symbolic page flag names in bad_page()
Message-ID: <20091207053806.GA17052@elte.hu>
References: <20091204212606.29258.98531.stgit@bob.kio>
 <20091206034636.GA7109@localhost>
 <20091206230016.GA18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091206230016.GA18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


* Andi Kleen <andi@firstfloor.org> wrote:

> > So how about this patch?
> 
> I like it. Decoding the flags by hand is always a very unpleasant 
> experience. Bonus: dump_page can be called from kgdb too.

Guys, please do more review:

> +void dump_page(struct page *page)
> +{
> +     char buf[1024];

NAK. This code causes a brutal, +1K kernel stack footprint spike that 
can crash a system _precisely_ when we are trying to dump a (presumably 
rare) condition.

> +EXPORT_SYMBOL(dump_page);

( Small detail: such exports are EXPORT_SYMBOL_GPL - we dont want random 
  external modules start using it. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
