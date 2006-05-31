Message-ID: <447CFEAA.5070206@yahoo.com.au>
Date: Wed, 31 May 2006 12:25:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU> <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU> <447C055A.9070906@sgi.com> <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Cc: Jes Sorensen <jes@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Cameron Davies wrote:

> Hi Jes
>
> I concede that I am acutely aware that 3.5% is just too high,  but we 
> know which abstractions are causing the problems.
>
> We will hope to nail down some of these problems in the next few weeks
> and then feed again.
>
> What level of degradation in peformance in acceptable (if any)?


For upstream inclusion? negative degradation, I'd assume: you're adding
significant complexity so there has to be some justification for it...

And unless it is something pretty significant, I'd almost bet that Linus,
if nobody else, will veto it. Our radix-tree v->p data structure is
fairly clean, performant, etc. It matches the logical->physical radix
tree data structure we use for pagecache as well.

BTW. I reckon your performance problems are due to indirect function
calls.

Nick

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
