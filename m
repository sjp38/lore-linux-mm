Message-ID: <46A6EE09.1030307@yahoo.com.au>
Date: Wed, 25 Jul 2007 16:30:33 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au>	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	 <46A58B49.3050508@yahoo.com.au>	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au> <b21f8390707242319gb17e4c9h274635b4c7fc1801@mail.gmail.com>
In-Reply-To: <b21f8390707242319gb17e4c9h274635b4c7fc1801@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Eric St-Laurent <ericstl34@sympatico.ca>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Rene Herman <rene.herman@gmail.com>
List-ID: <linux-mm.kvack.org>

Matthew Hawkins wrote:
> On 7/25/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> Not to say that neither fix some problems, but for such conceptually
>> big changes, it should take a little more effort than a constructed test
>> case and no consideration of the alternatives to get it merged.
> 
> 
> Swap Prefetch has existed since September 5, 2005.  Please Nick,
> enlighten us all with your "alternatives" which have been offered (in
> practical, not theoretical form) in the past 23 months, along with
> their non-constructed benchmarks proving their case and the hordes of
> happy users and kernel developers who have tested them out the wazoo
> and given their backing.  Or just take a nice steaming jug of STFU.

The alternatives comment was in relation to the readahead based drop
behind patch,for which an alternative would be improving use-once,
possibly in the way I described.

As for swap prefetch, I don't know, I'm not in charge of it being
merged or not merged. I do know some people have reported that their
updatedb problem gets much better with swap prefetch turned on, and
I am trying to work on that too.

For you? You also have the alternative to help improve things yourself,
and you can modify your own kernel.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
