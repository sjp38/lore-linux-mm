Date: Tue, 29 Jul 2008 09:28:53 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080729092853.0ddf7013@bree.surriel.com>
In-Reply-To: <87y73k4yhg.fsf@saeurebad.de>
References: <20080724222510.3bbbbedc@bree.surriel.com>
	<20080728105742.50d6514e@cuia.bos.redhat.com>
	<20080728164124.8240eabe.akpm@linux-foundation.org>
	<20080728195713.42cbceed@cuia.bos.redhat.com>
	<20080728200311.2218af4e@cuia.bos.redhat.com>
	<87y73k4yhg.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jul 2008 15:21:47 +0200
Johannes Weiner <hannes@saeurebad.de> wrote:

> Here is my original patch that just gets rid of it.  It did not cause
> any problems to me on high pressure.  Rik, you said on IRC that you now
> also think the patch is safe..?

Yes.  Removing the "+ 1" is safe because we do not scan until
zone->lru[l].nr_scan reaches swap_cluster_max, which means that
the scan counter for small lists will also slowly increase and
no list will be left behind.

> From: Johannes Weiner <hannes@saeurebad.de>
> Subject: mm: don't accumulate scan pressure on unrelated lists
> 
> During each reclaim scan we accumulate scan pressure on unrelated
> lists which will result in bogus scans and unwanted reclaims
> eventually.

This patch fixes the balancing issues that we have been seeing
with the split LRU VM currently in -mm.

It is my preferred patch because it removes magic from the VM,
instead of adding some.

> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
