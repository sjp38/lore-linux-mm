Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 053A76B00B1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:48:49 -0500 (EST)
Message-ID: <4B5F46FA.4030509@redhat.com>
Date: Tue, 26 Jan 2010 14:48:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
References: <patchbomb.1264513915@v2.random> <948638099c17d3da3d6f.1264513919@v2.random> <4B5F1460.7030106@redhat.com> <20100126171032.GS30452@random.random>
In-Reply-To: <20100126171032.GS30452@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 12:10 PM, Andrea Arcangeli wrote:
> On Tue, Jan 26, 2010 at 11:12:16AM -0500, Rik van Riel wrote:

>> Should the line above be "page_head = compound_head(page);" or
>> am I missing something?
>
> page_head = page is there because if this is not a tail page it's also
> the page_head. Only in case this is a tail page, compound_head is
> called, otherwise it's guaranteed unnecessary. And if it's a tail page
> compound_head has to run atomically inside irq disabled section
> __get_user_pages_fast before returning. Otherwise ->first_page won't
> be a stable pointer.

Ahh, I see it now.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
