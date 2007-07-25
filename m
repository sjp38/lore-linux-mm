Message-ID: <46A70299.50809@yahoo.com.au>
Date: Wed, 25 Jul 2007 17:58:17 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au> <Pine.LNX.4.64.0707242252250.2229@asgard.lang.hm> <46A6E80B.6030704@yahoo.com.au> <Pine.LNX.4.64.0707242316410.2229@asgard.lang.hm> <46A6FAD8.6050107@yahoo.com.au> <20070725074931.GA5125@elte.hu>
In-Reply-To: <20070725074931.GA5125@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: david@lang.hm, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>And yet despite my repeated pleas, none of those people has yet spent 
>>a bit of time with me to help analyse what is happening.
> 
> 
> btw., it might help to give specific, precise instructions about what 
> people should do to help you analyze this problem.

Ray has been the first one to offer (thank you), and yes I have asked
him for precise details of info to collect to hopefully work out what
is happening with his first problem.

For the general "it feels better for me" it is harder, but not as hard
as CPU scheduler. We can measure various types of IO waits, swap in/out
events, swap prefetch events and successfulness; see what happens to
those as we change swappiness or vfs_cache_pressure etc.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
