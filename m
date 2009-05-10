Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4C6E6B009C
	for <linux-mm@kvack.org>; Sun, 10 May 2009 08:19:03 -0400 (EDT)
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class  citizen
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090510114454.GA8891@localhost>
References: <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <20090510092053.GA7651@localhost>
	 <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
	 <20090510100335.GC7651@localhost>
	 <2f11576a0905100315j2c810e96mc29b84647dc565c2@mail.gmail.com>
	 <20090510112149.GA8633@localhost>
	 <2f11576a0905100439u38c8bccak355ec23953950d6@mail.gmail.com>
	 <20090510114454.GA8891@localhost>
Content-Type: text/plain
Date: Sun, 10 May 2009 14:19:08 +0200
Message-Id: <1241957948.9562.2.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-05-10 at 19:44 +0800, Wu Fengguang wrote:
> 
> > They always use mmap(PROT_READ | PROT_WRITE | PROT_EXEC) for anycase.
> > Please google it. you can find various example.
>  
> How widely is PROT_EXEC abused? Would you share some of your google results?

That's a security bug right there and should be fixed regardless of our
heuristics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
