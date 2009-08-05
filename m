Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 906F16B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 13:25:35 -0400 (EDT)
Message-ID: <4A79C076.2090000@redhat.com>
Date: Wed, 05 Aug 2009 13:25:10 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com> <4A7993F4.9020008@redhat.com> <20090805163143.GF23385@random.random>
In-Reply-To: <20090805163143.GF23385@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, Aug 05, 2009 at 10:15:16AM -0400, Rik van Riel wrote:
>> Not having a hardware accessed bit would explain why
>> the VM is not reactivating the pages that were accessed
>> while on the inactive list.
> 
> Problem is, even with young bit functional the VM isn't reactivating
> those pages anyway because of that broken check... 

That check is only done where active pages are moved to the
inactive list!   Inactive pages that were referenced always
get moved to the active list (except for unmapped file pages).

> I think it'll still better than current situation, as young bit is
> always set for ptes. Otherwise EPT pages are too penalized, we need
> them to stay one round more in active list like everything else.

NOTHING ELSE stays on the active anon list for two rounds,
for very good reasons.  Please read up on what has changed
in the VM since 2.6.27.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
