Message-ID: <49368DAF.9060206@redhat.com>
Date: Wed, 03 Dec 2008 08:46:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: improve reclaim throuput to bail out patch
References: <49316CAF.2010006@redhat.com> <20081130150849.8140.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081203140419.1D44.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081203140419.1D44.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
> I evaluate rvr bailout and skip-freeing patch in this week conteniously.
> I'd like to dump first output here.
> 
> 
> 
> Rik, could you please review following?
> ==
> vmscan bail out patch move nr_reclaimed variable to struct scan_control.
> Unfortunately, indirect access can easily happen cache miss.
> More unfortunately, Some architecture (e.g. ia64) don't access global
> variable so fast.

That is amazing.  Especially considering that the scan_control
is a local variable on the stack.

> if heavy memory pressure happend, that's ok.
> cache miss already plenty. it is not observable.
> 
> but, if memory pressure is lite, performance degression is obserbable.

> about 4-5% degression.
> 
> Then, this patch introduce temporal local variable.

> OK. the degression is disappeared.

I can't argue with the numbers, though :)

Maybe all the scanning we do ends up evicting the cache lines
with the scan_control struct in it from the fast part of the
CPU cache?

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
