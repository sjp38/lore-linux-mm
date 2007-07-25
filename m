Message-ID: <46A6D8DF.8060205@yahoo.com.au>
Date: Wed, 25 Jul 2007 15:00:15 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au>	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	 <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
In-Reply-To: <46A6D7D2.4050708@gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rene Herman wrote:
> On 07/25/2007 06:06 AM, Nick Piggin wrote:
> 
>> Ray Lee wrote:
> 
> 
>>> Anyway, my point is that I worry that tuning for an unusual and 
>>> infrequent workload (which updatedb certainly is), is the wrong way 
>>> to go.
>>
>>
>> Well it runs every day or so for every desktop Linux user, and it has
>> similarities with other workloads.
> 
> 
> It certainly doesn't run for me ever. Always kind of a "that's not the 
> point" comment but I just keep wondering whenever I see anyone complain 
> about updatedb why the _hell_ they are running it in the first place. If 
> anyone who never uses "locate" for anything simply disable updatedb, the 
> problem will for a large part be solved.
> 
> This not just meant as a cheap comment; while I can think of a few 
> similar loads even on the desktop (scanning a browser cache, a media 
> player indexing a large amount of media files, ...) I've never heard of 
> problems _other_ than updatedb. So just junk that crap and be happy.

OK fair point, but the counter point that there are real patterns
that just use-once a lot of metadata (ls, for example. grep even.)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
