Message-ID: <46134AA9.4080804@cosmosbay.com>
Date: Wed, 04 Apr 2007 08:50:17 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [patches] threaded vma patches (was Re: missing madvise functionality)
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org> <4612DCC6.7000504@cosmosbay.com> <46130BC8.9050905@yahoo.com.au> <46133A8B.50203@cosmosbay.com> <46134124.2040705@yahoo.com.au> <461348CD.9000200@redhat.com>
In-Reply-To: <461348CD.9000200@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper a A(C)crit :
> Nick Piggin wrote:
>> Sad. Although Ulrich did seem interested at one point I think? Ulrich,
>> do you agree at least with the interface that Eric is proposing?
> 
> I have no idea what you're talking about.
> 

You were CC on this one, you can find an archive here :

http://lkml.org/lkml/2007/3/15/230

This avoids mmap_sem for private futexes (PTHREAD_PROCESS_PRIVATE  semantic)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
