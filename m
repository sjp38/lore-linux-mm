Date: Sun, 2 Mar 2008 09:23:50 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 11/21] (NEW) more aggressively use lumpy reclaim
Message-ID: <20080302092350.684ca7f6@bree.surriel.com>
In-Reply-To: <20080302193024.1E72.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080228192908.126720629@redhat.com>
	<20080228192928.954667833@redhat.com>
	<20080302193024.1E72.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, 02 Mar 2008 19:35:44 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> I think this patch is very good improvement.
> but it is not related to split lru.
> 
> Why don't you separate this patch?
> IMHO treat as independent patch is better.

Agreed, I should probably pull this to the start of the patch series
and submit it to Andrew Morton soon.

The arrayification of the LRU lists and pagevecs should probably go
into -mm soon, as well.  That code is ready and it can be merged
independently of the split VM code.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
