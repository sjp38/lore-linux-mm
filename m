Date: Wed, 30 May 2007 11:12:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Make dynamic/run-time configuration of zonelist order
 configurable
Message-Id: <20070530111212.095350d2.akpm@linux-foundation.org>
In-Reply-To: <1180468121.5067.64.camel@localhost>
References: <1180468121.5067.64.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 May 2007 15:48:41 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> [PATCH] Make dynamic/run-time configuration of zonelist order configurable
> 
> Against 2.6.22-rc2-mm1 with the huge page allocation fix applied:
> 
> 	http://marc.info/?l=linux-mm&m=117935390224779&w=4
> 

I wasn't cc'ed on "[PATCH/RFC] Fix hugetlb pool allocation with empty nodes
- V4" so I didn't apply it hence cannot apply this.

Plus I'd prefer not to, really.  This patch should be folded into
change-zonelist-order-zonelist-order-selection-logic.patch somehow, but I
cannot do that if it is dependent upon the unrelated "[PATCH/RFC] Fix
hugetlb pool allocation with empty nodes - V4".

Better would be to raise a patch relative to the change-zonelist-order-*
patches, please.  Then we can take a look at the hugetlb fix independently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
