Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2FE7F6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 08:49:47 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so225558waf.22
        for <linux-mm@kvack.org>; Thu, 19 Feb 2009 05:49:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235049334.29813.18.camel@penberg-laptop>
References: <20090218093858.8990.A69D9226@jp.fujitsu.com>
	 <1234944569.24030.20.camel@penberg-laptop>
	 <20090219085229.954A.A69D9226@jp.fujitsu.com>
	 <1235034967.29813.10.camel@penberg-laptop>
	 <2f11576a0902190451w294aa2fan29b61fa3619f459b@mail.gmail.com>
	 <1235049334.29813.18.camel@penberg-laptop>
Date: Thu, 19 Feb 2009 22:49:43 +0900
Message-ID: <2f11576a0902190549p2d3c90e2md16726cbe2f5d019@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator (try 2)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

>> Honestly, I'm bit confusing.
>> above url's patch use PAGE_SIZE, but not 4K nor architecture independent value.
>> Your 4K mean PAGE_SIZE?
>
> Yes, I mean PAGE_SIZE. 4K page sizes are hard-wired into my brain,
> sorry :-)

Thanks!
I'm recovered from confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
