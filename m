Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7114D6003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 10:01:47 -0500 (EST)
Message-ID: <4B5F037D.9050801@redhat.com>
Date: Tue, 26 Jan 2010 10:00:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03 of 31] alter compound get_page/put_page
References: <patchbomb.1264513915@v2.random> <936cd613e4ae2d20c62b.1264513918@v2.random>
In-Reply-To: <936cd613e4ae2d20c62b.1264513918@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 08:51 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Alter compound get_page/put_page to keep references on subpages too, in order
> to allow __split_huge_page_refcount to split an hugepage even while subpages
> have been pinned by one of the get_user_pages() variants.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Ahh, I see you added the #ifdef in this patch.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
