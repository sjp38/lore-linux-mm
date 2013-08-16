Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 882266B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 07:28:53 -0400 (EDT)
Date: Fri, 16 Aug 2013 13:28:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please continue
 your great work! :-)
Message-ID: <20130816112832.GY24092@twins.programming.kicks-ass.net>
References: <20130814174039.GA24033@dhcp22.suse.cz>
 <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
 <20130814182756.GD24033@dhcp22.suse.cz>
 <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
 <520C9E78.2020401@gmail.com>
 <CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
 <CA+55aFxuUrcod=X2t2yqR_zJ4s1uaCsGB-p1oLTQrG+y+Z2PbA@mail.gmail.com>
 <520D5ED2.9040403@gmail.com>
 <CA+55aFwFx7uhtDTX5vfiYRo+keLmuvxvSFupU4nB8g1KCN-WVg@mail.gmail.com>
 <20130816110031.GA13507@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130816110031.GA13507@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ben Tebulin <tebulin@googlemail.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Fri, Aug 16, 2013 at 01:00:31PM +0200, Michal Hocko wrote:

> I was thinking about teaching __tlb_remove_page to update the range
> automatically from the given address.

The mmu_gather unification stuff I had did it differently still:

  http://permalink.gmane.org/gmane.linux.kernel.mm/81287

That said, I do like Linus' approach. The only thing I haven't
considered is if it does the right thing for tile,mips-r4k which have
'special' rules for VM_HUGETLB. Although I don't think it changes those
archs enough to break anything.

I should find some time to finally finish that series :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
