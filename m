Date: Wed, 5 Apr 2006 09:28:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Lhms-devel] [RFC 0/6] Swapless Page Migration V1: Overview
In-Reply-To: <1144248362.5203.22.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604050925110.1387@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
 <1144248362.5203.22.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Apr 2006, Lee Schermerhorn wrote:

> Does this approach still allow "migrate-on-fault" for anon pages?

I am not aware of something that would be in the way.

> Especially, in the case where the migrating page has >1 pte referencing
> it?  How will the fault handler find all of the pte's referencing the
> old page?  Actually, I don't think we'd want to burden the task whose

The fault handler can find these via the reverse maps.

> fault caused the migration with finding and replacing and replacing all
> pte's referecing the old page.  Using a real cache, this isn't a problem
> because we replace the old page with a new one in the cache, and the
> cache ptes reference the cache entry.  Tasks are free to fault in a real
> pte for the new page at any time.  I'd hate to lose this capability.  I
> believe that this is one of the reasons that Marcello used a real idr-
> based cache for the migration cache.

We never allow a faulting in of the new page before migration is 
complete. The replacing of the swap ptes with real ptes was always done 
after migration was complete. Same thing here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
