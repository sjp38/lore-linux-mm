Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 1527D6B0062
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 12:52:09 -0400 (EDT)
Message-ID: <4FEDDD0C.60609@redhat.com>
Date: Fri, 29 Jun 2012 12:51:24 -0400
From: Dor Laor <dlaor@redhat.com>
Reply-To: dlaor@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com>
In-Reply-To: <20120629125517.GD32637@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Hillf Danton <dhillf@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/29/2012 08:55 AM, Ingo Molnar wrote:
>
> * Hillf Danton <dhillf@gmail.com> wrote:
>
>> On Thu, Jun 28, 2012 at 10:53 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>>>
>>> Unless you're going to listen to feedback I give you, I'm
>>> going to completely stop reading your patches, I don't give
>>> a rats arse you work for the same company anymore.
>>
>> Are you brought up, Peter, in dirty environment with mind
>> polluted?
>
> You do not seem to be aware of the history of this patch-set,
> I suspect Peter got "polluted" by Andrea ignoring his repeated
> review feedbacks...

AFAIK, Andrea answered many of Peter's request by reducing the memory 
overhead, adding documentation and changing the scheduler integration.

When someone plants 'crap' too much in his comments, its not a surprise 
that some will get ignored. Moreover, I don't think the decent comments 
got ignored, sometimes both were talking in parallel lines - even in 
this case, it's hard to say whether Peter's like to add ia64 support or 
just like to get rid of the forceful migration as a whole.

Since it takes more time to fully understand the code than to write the 
comments, I suggest to go the extra mile there and make sure the review 
is crystal clear.

>
> If his multiple rounds of polite (and extensive) review didn't
> have much of an effect then maybe some amount of not so nice
> shouting has more of an effect?
>
> The other option would be to NAK and ignore the patchset, in
> that sense Peter is a lot more constructive and forward looking
> than a polite NAK would be, even if the language is rough.

NAK is better w/ further explanation or even suggestion about 
alternatives. The previous comments were not shouts but the mother of 
all NAKs.

There are some in the Linux community that adore flames but this is a 
perfect example that this approach slows innovation instead of advance it.

Some developers have a thick skin and nothing gets in, others are human 
and have feelings. Using a tiny difference in behavior we can do much 
much better. What's works in a f2f loud discussion doesn't play well in 
email.

Or alternatively:

/*
  * can_nice - check if folks on lkml can be nicer&productive
  * @p: person
  * @nice: nice value
  * Since nice isn't a negative property, nice is an uint here.
  */
int can_nice(const struct person *p, const unsigned int nice)
{
         int nice_rlim = MAX_LIMIT_BEFORE_NAK;

         BUG_ON(!capable(CAP_SYS_NICE));

         if (nice_rlim >= task_rlimit(p, RLIMIT_NICE))
            printk(KERN_INFO "Please NAK w/ decent explanation or \
            submit an alternative patch);

         return 0;
}

Ingo, what's your technical perspective of this particular patch?

Cheers,
Dor

>
> Thanks,
>
> 	Ingo
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
