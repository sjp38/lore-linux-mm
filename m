Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 243A26B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 11:19:47 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id a3so2077388oib.8
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:19:46 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id mg16si11195866oeb.36.2015.01.22.08.19.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 08:19:46 -0800 (PST)
Message-ID: <1421943573.4903.24.camel@stgolabs.net>
Subject: Re: [PATCH] mm, vmacache: Add kconfig VMACACHE_SHIFT
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 22 Jan 2015 08:19:33 -0800
In-Reply-To: <20150122075742.GA11335@dhcp-129-179.nay.redhat.com>
References: <1421908189-18938-1-git-send-email-chaowang@redhat.com>
	 <1421912761.4903.22.camel@stgolabs.net>
	 <20150122075742.GA11335@dhcp-129-179.nay.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2015-01-22 at 15:57 +0800, WANG Chao wrote:
> Hi, Davidlohr
> 
> On 01/21/15 at 11:46pm, Davidlohr Bueso wrote:
> > On Thu, 2015-01-22 at 14:29 +0800, WANG Chao wrote:
> > > Add a new kconfig option VMACACHE_SHIFT (as a power of 2) to specify the
> > > number of slots vma cache has for each thread. Range is chosen 0-4 (1-16
> > > slots) to consider both overhead and performance penalty. Default is 2
> > > (4 slots) as it originally is, which provides good enough balance.
> > > 
> > 
> > Nack. I don't feel comfortable making scalability features of core code
> > configurable.
> 
> Out of respect, is this a general rule not making scalability features
> of core code configurable?

I doubt its a rule, just common sense. Users have no business
configuring such low level details. The optimizations need to
transparently work for everyone.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
