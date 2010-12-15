Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCAE6B0095
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 04:26:05 -0500 (EST)
Message-ID: <4D08899F.4050502@akana.de>
Date: Wed, 15 Dec 2010 10:25:51 +0100
From: Ingo Korb <ingo@akana.de>
MIME-Version: 1.0
Subject: Re: PROBLEM: __offline_isolated_pages may offline too many pages
References: <4D0786D3.7070007@akana.de> <20101215092134.e2c8849f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101215092134.e2c8849f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, cl@linux-foundation.org, yinghai@kernel.org, andi.kleen@intel.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 15.12.2010 01:21, KAMEZAWA Hiroyuki wrote:

> It's designed for offline memory section>  MAX_ORDER. pageblock_nr_pages
> is tend to be smaller than that.
>
> Do you see the problem with _exsisting_ user interface of memory hotplug ?
> I think we have no control other than memory section.

The existing, exported interface (remove_memory() - the check itself is 
in offline_pages()) only checks if both start and end of the 
to-be-removed block are aligned to pageblock_nr_pages. As you noted the 
actual size and alignment requirements in __offline_isolated_pages can 
be larger that that, so I think the checks in offline_pages() should be 
changed (if 1<<MAX_ORDER is always >= pageblock_nr_pages) or extended 
(if there can be any relation between the two).

-ik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
