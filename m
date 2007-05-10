Message-ID: <46429801.8030202@yahoo.com.au>
Date: Thu, 10 May 2007 13:56:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org>	 <200705100928.34056.kernel@kolivas.org>	 <464261B5.6030809@yahoo.com.au>	 <200705101134.34350.kernel@kolivas.org> <46427BDB.30004@yahoo.com.au> <2c0942db0705092048m38b36e7fo3a7c2c59fe1612b2@mail.gmail.com>
In-Reply-To: <2c0942db0705092048m38b36e7fo3a7c2c59fe1612b2@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Con Kolivas <kernel@kolivas.org>, Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:
> On 5/9/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> You said it helped with the updatedb problem. That says we should look at
>> why it is going bad first, and for example improve use-once algorithms.
>> After we do that, then swap prefetching might still help, which is fine.
> 
> 
> Nick, if you're volunteering to do that analysis, then great. If not,
> then you're just providing a airy hope with nothing to back up when or
> if that work would ever occur.

I'd like to try helping. Tell me your problem.


> Further, if you or someone else *does* do that work, then guess what,
> we still have the option to rip out the swap prefetching code after
> the hypothetical use-once improvements have been proven and merged.
> Which, by the way, I've watched people talk about since 2.4. That was,
> y'know, a *while* ago.

What's wrong with the use-once we have? What improvements are you talking
about?


> So enough with the stop energy, okay? You're better than that.

I don't think it is about energy or being mean, I'm just stating the
issues I have with it.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
