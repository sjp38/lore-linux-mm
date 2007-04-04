Message-ID: <461347D1.6000508@yahoo.com.au>
Date: Wed, 04 Apr 2007 16:38:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patches] threaded vma patches (was Re: missing madvise functionality)
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com>	<20070403144948.fe8eede6.akpm@linux-foundation.org>	<4612DCC6.7000504@cosmosbay.com>	<46130BC8.9050905@yahoo.com.au>	<46133A8B.50203@cosmosbay.com>	<46134124.2040705@yahoo.com.au> <20070403232624.11935e80.akpm@linux-foundation.org>
In-Reply-To: <20070403232624.11935e80.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

(sorry to change the subjet, I was initially going to send the
threaded vma cache patches on list, but then decided they didn't
have enough changelog!)

Andrew Morton wrote:
> On Wed, 04 Apr 2007 16:09:40 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Andrew, do you have any objections to putting Eric's fairly
>>important patch at least into -mm?
> 
> 
> you know what to do ;)
> 

Well I did review them when he last posted, but simply didn't have
much to say (that happened in a much older discussion about the
private futex problem, and I ended up agreeing with this approach).
Anyway I'll have another look when they get posted again.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
