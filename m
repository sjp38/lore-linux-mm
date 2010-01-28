Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F04676B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 20:22:44 -0500 (EST)
Message-ID: <4B60E6BA.8010303@redhat.com>
Date: Wed, 27 Jan 2010 20:22:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 30 of 31] transparent hugepage vmstat
References: <patchbomb.1264513915@v2.random> <d75b849a4142269635e1.1264513945@v2.random> <4B5F72FF.9080204@redhat.com> <20100128010449.GE24242@random.random>
In-Reply-To: <20100128010449.GE24242@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/27/2010 08:04 PM, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 05:55:59PM -0500, Rik van Riel wrote:
>> Does this have the potential to unbalance the pageout code, by
>> not counting the hugepages at all?  (as opposed to counting a
>> hugepage as 1 page)
>
> When I checked it looked like this wasn't used by the pageout code.

You're right.  I got confused with the stats that the LRU
code maintains.  31 patches is entirely too much in one
review sitting :)

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
