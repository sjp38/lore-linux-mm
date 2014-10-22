Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 18C3F6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:44:21 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id bs8so1415624wib.11
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 06:44:21 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id v9si2028637wjv.117.2014.10.22.06.44.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 06:44:20 -0700 (PDT)
Date: Wed, 22 Oct 2014 15:44:16 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 3/6] mm: VMA sequence count
Message-ID: <20141022134416.GA15602@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.361741939@infradead.org>
 <20141022112657.GG30588@node.dhcp.inet.fi>
 <20141022113951.GB21513@worktop.programming.kicks-ass.net>
 <20141022115304.GA31486@node.dhcp.inet.fi>
 <20141022121554.GD21513@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022121554.GD21513@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 22, 2014 at 02:15:54PM +0200, Peter Zijlstra wrote:
> On Wed, Oct 22, 2014 at 02:53:04PM +0300, Kirill A. Shutemov wrote:
> > Em, no. In this case change_protection() will not touch the pte, since
> > it's pte_none() and the pte_same() check will pass just fine.
> 
> Oh, that's what you meant. Yes that's a problem, yes vm_page_prot
> needs wrapping too.

Maybe also vm_policy, is there anything else that can change while a vma
lives?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
