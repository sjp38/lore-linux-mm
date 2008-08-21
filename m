Message-ID: <48AD6B20.1080105@linux-foundation.org>
Date: Thu, 21 Aug 2008 08:18:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080820113131.f032c8a2.akpm@linux-foundation.org> <20080821024240.GC23397@sgi.com> <48AD689F.6080103@linux-foundation.org> <20080821131404.GC26567@sgi.com>
In-Reply-To: <20080821131404.GC26567@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tokunaga.keiich@jp.fujitsu.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:

>> We removed this code because it frees a page before the TLB flush has been
>> performed. This code segment was the reason that quicklists were not accepted
>> for x86.
> 
> How could we do this.  It was a _HUGE_ problem on altix boxes.  When you
> started a jobs with a large number of MPI ranks, they would all start
> from the shepherd process on a single node and the children would
> migrate to a different cpu.  Unless subsequent jobs used enough memory
> to flush those remote quicklists, we would end up with a depleted node
> that never reclaimed.

Well I tried to get the quicklist stuff resolved at SGI multiple times last
year when the early free before flush was discovered but there did not seem to
be much interest at that point, so we dropped it.

In order to make this work correctly we would need to create a list of remote
pages. These remote pages would then be freed after the TLB flush.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
