Date: Tue, 24 Jul 2007 22:53:52 -0700 (PDT)
From: david@lang.hm
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6E1A1.4010508@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0707242252250.2229@asgard.lang.hm>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
 <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
  <46A58B49.3050508@yahoo.com.au>  <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
  <46A6CC56.6040307@yahoo.com.au>  <46A6D7D2.4050708@gmail.com>
 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Nick Piggin wrote:

> Eric St-Laurent wrote:
>>  On Wed, 2007-25-07 at 06:55 +0200, Rene Herman wrote:
>>
>> 
>> > It certainly doesn't run for me ever. Always kind of a "that's not the 
>> > point" comment but I just keep wondering whenever I see anyone complain 
>> > about updatedb why the _hell_ they are running it in the first place. If 
>> > anyone who never uses "locate" for anything simply disable updatedb, the 
>> > problem will for a large part be solved.
>> > 
>> > This not just meant as a cheap comment; while I can think of a few 
>> > similar loads even on the desktop (scanning a browser cache, a media 
>> > player indexing a large amount of media files, ...) I've never heard of 
>> > problems _other_ than updatedb. So just junk that crap and be happy.
>>
>> 
>> >From my POV there's two different problems discussed recently:
>>
>>  - updatedb type of workloads that add tons of inodes and dentries in the
>>  slab caches which of course use the pagecache.
>>
>>  - streaming large files (read or copying) that fill the pagecache with
>>  useless used-once data
>>
>>  swap prefetch fix the first case, drop-behind fix the second case.
>
> OK, this is where I start to worry. Swap prefetch AFAIKS doesn't fix
> the updatedb problem very well, because if updatedb has caused swapout
> then it has filled memory, and swap prefetch doesn't run unless there
> is free memory (not to mention that updatedb would have paged out other
> files as well).
>
> And drop behind doesn't fix your usual problem where you are downloading
> from a server, because that is use-once write(2) data which is the
> problem. And this readahead-based drop behind also doesn't help if data
> you were reading happened to be a sequence of small files, or otherwise
> not in good readahead order.
>
> Not to say that neither fix some problems, but for such conceptually
> big changes, it should take a little more effort than a constructed test
> case and no consideration of the alternatives to get it merged.

well, there appears to be a fairly large group of people who have 
subjective opinions that it helps them. but those were dismissed becouse 
they aren't measurements.

so now the measurements of the constructed test case aren't acceptable.

what sort of test case would be acceptable?

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
