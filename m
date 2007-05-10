Message-ID: <46427BDB.30004@yahoo.com.au>
Date: Thu, 10 May 2007 11:56:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705100928.34056.kernel@kolivas.org> <464261B5.6030809@yahoo.com.au> <200705101134.34350.kernel@kolivas.org>
In-Reply-To: <200705101134.34350.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Thursday 10 May 2007 10:05, Nick Piggin wrote:

>>I'm not the gatekeeper and it is completely up to you whether you want
>>to work on something or not... but I'm sure you understand where I was
>>coming from when I suggested it doesn't get merged yet.
> 
> 
> No matter how you spin it, you're the gatekeeper.

If raising unaddressed issues means closing a gate, then OK. You can
equally open it by answering them.


>>You may not believe this, but I agree that swap prefetching (and
>>prefetching in general) has some potential to help desktop workloads :).
>>But it still should go through the normal process of being tested and
>>questioned and having a look at options for first improving existing
>>code in those problematic cases.
> 
> 
> Not this again? Proof was there ages ago that it helped and no proof that it 
> harmed could be found yet you cunningly pretend it never existed. It's been 
> done to death and I'm sick of this.

I said I know it can help. Do you know how many patches I have that help
some workloads but are not merged? That's just the way it works.

What I have seen is it helps the case where you force out a huge amount
of swap. OK, that's nice -- the base case obviously works.

You said it helped with the updatedb problem. That says we should look at
why it is going bad first, and for example improve use-once algorithms.
After we do that, then swap prefetching might still help, which is fine.


>>Once that process happens and it is shown to work nicely, etc., then I
>>would not be able to (or want to) keep it from getting merged.
>>
>>As far as cpusets goes... if your code goes in last, then you have to
>>make it work with what is there, as a rule. People are using cpusets
>>for memory resource control, which would have uses on a desktop system.
>>It is just a really bad precedent to set, having different parts of the
>>VM not work correctly together. Even if you made them mutually
>>exclusive CONFIG_ options, that is still not a very nice solution.
> 
> 
> That's as close to a 3 as I'm likely to get out of you.

If you're not willing to try making it work with existing code, among other
things, then yes it will be difficult to get it merged. That's not going to
change.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
