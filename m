From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 0/4] Bootmem cleanups
References: <20080430170521.246745395@symbol.fehenstaub.lan>
	<20080430184352.GE3008@elte.hu>
Date: Thu, 01 May 2008 12:22:30 +0200
In-Reply-To: <20080430184352.GE3008@elte.hu> (Ingo Molnar's message of "Wed,
	30 Apr 2008 20:43:52 +0200")
Message-ID: <87iqxyz5ll.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

Ingo Molnar <mingo@elte.hu> writes:

> * Johannes Weiner <hannes@saeurebad.de> wrote:
>
>> Hi Ingo,
>> 
>> I now dropped the node-crossing patches from my bootmem series and 
>> here is what is left over.
>> 
>> They apply to Linus' current git 
>> (0ff5ce7f30b45cc2014cec465c0e96c16877116e).
>> 
>> Please note that all parts affecting !X86_32_BORING_UMA_BOX are 
>> untested!
>> 
>>  arch/alpha/mm/numa.c             |    8 ++--
>>  arch/arm/mm/discontig.c          |   34 ++++++++++-----------
>>  arch/ia64/mm/discontig.c         |   11 +++----
>>  arch/m32r/mm/discontig.c         |    4 +--
>>  arch/m68k/mm/init.c              |    4 +--
>>  arch/mips/sgi-ip27/ip27-memory.c |    3 +-
>>  arch/parisc/mm/init.c            |    3 +-
>>  arch/powerpc/mm/numa.c           |    3 +-
>>  arch/sh/mm/numa.c                |    5 +--
>>  arch/sparc64/mm/init.c           |    3 +-
>>  arch/x86/mm/discontig_32.c       |    3 +-
>>  arch/x86/mm/numa_64.c            |    6 +---
>>  include/linux/bootmem.h          |    7 +---
>>  mm/bootmem.c                     |   59 ++++++++++++++++++-------------------
>>  mm/page_alloc.c                  |    4 +--
>>  15 files changed, 67 insertions(+), 90 deletions(-)
>
> i've read them and the changes all look sane and well-structured - but 
> the impact is way too cross-arch for this to even touch x86.git i guess. 
> I suspect this is for -mm?

Sorry, misunderstanding.  I did not send it to the x86 guy but rather
the bootmem guy ;)

Andrew took them into -mm.

Thanks for your review!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
