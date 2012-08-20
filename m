Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D83806B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:35:15 -0400 (EDT)
Date: Mon, 20 Aug 2012 19:35:14 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/5] mempolicy: Remove mempolicy sharing
In-Reply-To: <1345480594-27032-3-git-send-email-mgorman@suse.de>
Message-ID: <00000139458826d2-f72fceae-338d-4f6c-84f3-67d8817ece99-000000@email.amazonses.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 20 Aug 2012, Mel Gorman wrote:

> Ideally, the shared policy handling would be rewritten to either properly
> handle COW of the policy structures or at least reference count MPOL_F_SHARED
> based exclusively on information within the policy.  However, this patch takes
> the easier approach of disabling any policy sharing between VMAs. Each new
> range allocated with sp_alloc will allocate a new policy, set the reference
> count to 1 and drop the reference count of the old policy. This increases
> the memory footprint but is not expected to be a major problem as mbind()
> is unlikely to be used for fine-grained ranges. It is also inefficient
> because it means we allocate a new policy even in cases where mbind_range()
> could use the new_policy passed to it. However, it is more straight-forward
> and the change should be invisible to the user.


Hmmm. I dont like the additional memory use but this is definitely an
issue that needs addressing.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
