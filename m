Date: Tue, 24 Jul 2007 22:12:12 -0700 (PDT)
From: david@lang.hm
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6D7D2.4050708@gmail.com>
Message-ID: <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
 <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
  <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Rene Herman wrote:

> On 07/25/2007 06:06 AM, Nick Piggin wrote:
>
>>  Ray Lee wrote:
>
>> >  Anyway, my point is that I worry that tuning for an unusual and 
>> >  infrequent workload (which updatedb certainly is), is the wrong way to 
>> >  go.
>>
>>  Well it runs every day or so for every desktop Linux user, and it has
>>  similarities with other workloads.
>
> It certainly doesn't run for me ever. Always kind of a "that's not the point" 
> comment but I just keep wondering whenever I see anyone complain about 
> updatedb why the _hell_ they are running it in the first place. If anyone who 
> never uses "locate" for anything simply disable updatedb, the problem will 
> for a large part be solved.
>
> This not just meant as a cheap comment; while I can think of a few similar 
> loads even on the desktop (scanning a browser cache, a media player indexing 
> a large amount of media files, ...) I've never heard of problems _other_ than 
> updatedb. So just junk that crap and be happy.

but if you do use locate then the alturnative becomes sitting around and 
waiting for find to complete on a regular basis.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
