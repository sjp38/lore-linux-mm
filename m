Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id CAA416B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 16:34:02 -0400 (EDT)
Date: Tue, 26 Jun 2012 22:34:00 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio ballooned pages
Message-ID: <20120626203400.GA11413@one.firstfloor.org>
References: <cover.1340665087.git.aquini@redhat.com> <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com> <20120626101729.GF8103@csn.ul.ie> <20120626165258.GY11413@one.firstfloor.org> <20120626201513.GJ8103@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626201513.GJ8103@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org

> How is the compiler meant to optimise away "cond" if it's a function
> call?

Inlines can be optimized away.  These tests are usually inlines.

> What did I miss? If nothing, then I will revert this particular change
> and Rafael will need to be sure his patch is not using VM_BUG_ON to call
> a function with side-effects.

Do you have an example where the code is actually different,
or are you just speculating?

FWIW for my config both generates the same code:

size vmlinux-andi-vmbug vmlinux-vmbug-nothing 
   text    data     bss     dec     hex filename
11809704        1457352 1159168 14426224         dc2070 vmlinux-andi-vmbug
11809704        1457352 1159168 14426224         dc2070 vmlinux-vmbug-nothing

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
