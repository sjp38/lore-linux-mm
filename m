Message-ID: <46A83C7A.80601@yahoo.com.au>
Date: Thu, 26 Jul 2007 16:17:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	<9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	<46A57068.3070701@yahoo.com.au>	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	<46A58B49.3050508@yahoo.com.au>	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	<46A6CC56.6040307@yahoo.com.au>	<46A6D7D2.4050708@gmail.com>	<1185341449.7105.53.camel@perkele>	<46A6E1A1.4010508@yahoo.com.au>	<2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com>	<20070725215717.df1d2eea.akpm@linux-foundation.org>	<46A836E1.1000404@yahoo.com.au> <20070725230609.d2d1be59.akpm@linux-foundation.org>
In-Reply-To: <20070725230609.d2d1be59.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ray Lee <ray-lk@madrabbit.org>, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 26 Jul 2007 15:53:37 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Not that I want to say anything about swap prefetch getting merged: my
>>inbox is already full of enough "helpful suggestions" about that,
> 
> 
> give them the kernel interfaces, they can do it themselves ;)

It is a good idea if we can give enough to get started. Then if
they run into something they really need to do in the kernel, we
can take a look.

Page eviction order / prefetch-back-in-order might be tricky to
expose.


>>so I'll
>>just be happy to have a look at little things like updatedb.
> 
> 
> Yes, that is a little thing.  I mean, even if the kernel's behaviour
> during an updatedb run was "perfect" (ie: does what we the designers
> curently intend it to do (whatever that is)) then the core problem isn't
> solved: short-term workload evicts your working set and you have to
> synchronously reestablish it.

Sure, I know and I was never against swap (and/or file) prefetching to
solve this problem. I'm just saying, I'm staying out of that :)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
