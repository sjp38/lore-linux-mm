Message-ID: <456D5347.3000208@yahoo.com.au>
Date: Wed, 29 Nov 2006 20:30:47 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: The VFS cache is not freed when there is not enough free memory
 to allocate
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>	 <1164185036.5968.179.camel@twins>	 <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>	 <456A964D.2050004@yahoo.com.au>	 <4e5ebad50611282317r55c22228qa5333306ccfff28e@mail.gmail.com> <6d6a94c50611290127u2b26976en1100217a69d651c0@mail.gmail.com>
In-Reply-To: <6d6a94c50611290127u2b26976en1100217a69d651c0@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: Sonic Zhang <sonic.adi@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vapier.adi@gmail.com
List-ID: <linux-mm.kvack.org>

Aubrey wrote:
> On 11/29/06, Sonic Zhang <sonic.adi@gmail.com> wrote:
> 
>> Forward to the mailing list.
>>
>> > On 11/27/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>
>>
>> >> I haven't actually written any nommu userspace code, but it is obvious
>> >> that you must try to keep malloc to <= PAGE_SIZE (although order 2 and
>> >> even 3 allocations seem to be reasonable, from process context)... 
>> Then
>> >> you would use something a bit more advanced than a linear array to 
>> store
>> >> data (a pagetable-like radix tree would be a nice, easy idea).
>> >>
>> >
>> > But, even we split the 8M memory into 2048 x 4k blocks, we still face
>> > this failure. The key problem is that available memory is small than
>> > 2048 x 4k, while there are still a lot of VFS cache. The VFS cache can
>> > be freed, but kernel allocation function ignores it. See the new test
>> > application.
>>
>>
>> Which kernel allocation function? If you can provide more details I'd
>> like to get to the bottom of this.
> 
> 
> I posted it here, I think you missed it. So forwarded it to you.

That was the order-9 allocation failure. Which is not going to be
solved properly by just dropping caches.

But Sonic apparently saw failures with 4K allocations, where the
caches weren't getting shrunk properly. This would be more interesting
because it would indicate a real problem with the kernel.

>>
>> Also, do you happen to know of a reasonable toolchain + emulator setup
>> that I could test the nommu kernel with?
> 
> 
> A project named skyeye.
> http://www.skyeye.org/index.shtml

Thanks, I'll give that one a try.

Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
