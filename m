Message-ID: <39AA5D41.C59CC2DE@tuke.sk>
Date: Mon, 28 Aug 2000 14:38:25 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A4F548.B8EB5308@tuke.sk> <20000828154744.A3741@saw.sw.com.sg> <39AA30AF.14C17C50@tuke.sk> <20000828193032.B5579@saw.sw.com.sg>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: linux-mm@kvack.org, Yuri Pudgorodsky <yur@asplinux.ru>
List-ID: <linux-mm.kvack.org>

Andrey Savochkin wrote:
> 
> On Mon, Aug 28, 2000 at 11:28:15AM +0200, Jan Astalos wrote:
> > Andrey Savochkin wrote:
> > > I don't think that personal swapfiles is an efficient approach to achieve
> > > QoS.  Most of the space will be reserved for exceptional cases, and, thus,
> > > wasted, as Yuri has mentioned.  A shared swap space allowing exceeding the
> > > guaranteed amount (if the memory isn't really used) is much more efficient
> > > spending of the space.  If the system has some spare memory, users exceeding
> > > their limits may still use it (but, certainly, only if only some of them, not
> > > all, exceed the limits).  Moreover, if some users don't consume all the
> > > memory guaranteed to them, others may temporarily use it.
> >
> > I think I explained my points clearly enough in my second reply to Yuri so I won't
> > repeat it again.
> >
> > I still claim that per user swapfiles will:
> > - be _much_ more efficient in the sense of wasting disk space (saving money)
> >   because it will teach users efficiently use their memory resources (if
> >   user will waste the space inside it's own disk quota it will be his own
> >   problem)
> > - provide QoS on VM memory allocation to users (will guarantee amount of
> >   available VM for user)
> > - be able to improve _per_user_ performance of system (localizing performance
> >   problems to users that caused them and reducing disk seek times)
> > - shift the problem with OOM from system to user.
> 
> Ok, tell me: if user A has swapfile of 10MB and doesn't use it, whether user
> B is allowed to use it meanwhile?
> If the answer is no, it's a waste of space, as I said.

As a user, you would waste 10MB of your 20MB quota ? I don't think so...

> If the answer is yes, I don't buy your argument of better clustering and less
> fragmentation.

Do you really need to post questions like that ? It's obvious that swapfiles would
be protected from access by another users. That's why they will be _personal_.

> 
> >From my point of view, the real topics are
> 1. memory QoS, which starts from controlled sharing of in-core memory between
>    users and, then, sharing of swap space, and the swap storage organization
>    (per-user or global) being a second-order question because separate
>    storages may easily be "emulated" by just quotas, and visa versa;

How the quotas will give you per user clustered pages ? If the quotas will
change who will maintain them, sysadmin ? Look, how much of system maintenance cost
is cost of system administration ? Still convinced that quotas on VM are good
idea ?

> 2. swap-out clusterization.
> Speaking about the clusterization, the current code already keeps this aspect
> in mind.  It may be more or less efficient, but it's a separate topic.

? OK. Your are aimed on management of physical memory. I _is_ important.
I'm aimed on VM QoS guaranties. From my point of view this is important too...
As I said, MM of physical memory is core of QoS. But without VM QoS there
wouldn't be _any_ memory QoS at all.

> 
> > I think that your beancounter is a big step towards good QoS in Linux MM, but
> > I'm a bit confused when I'll hear "...users exceeding their limits". What's the
> > limit good for if it can be exceeded ? Can you rethought the term ?
> 
> Well, I usually call them "thresholds" rather than "limits".
> Users are guaranteed to have some quality of service below the these
> thresholds, i.e. that their allocations succeed, that the processes aren't
> killed because of OOM, that the pages aren't swapped out.
> Over the thresholds the resources are given and requests are served on the
> best-effort basis.
> 
> > Can you describe how to avoid VM shortage by beancounter ?
> 
> I don't want to avoid VM shortage.
> The goal is to introduce different levels of service and allows
> administrators to manage it.

excellent. If you'll make it flexible enough to make adding of new MM
policy straightforward, you'll have my thanks...

> Users obeying their "contracts" (staying below the thresholds set for them)
> have some guarantees.  The guarantees are real if the administrator ensures
> that the sum of guaranteed amounts of resources is not greater than what's
> available.
> Users disobeying their "contracts" may face negative effects with the chances
> depending on the amount of unused resources and the degree of their
> violation.
> 
> VM shortage is possible (and total avoiding it is very inefficient).
> The goal is to make its consequences controllable, guarantee that certain
> processes will never suffer from it etc.

I can't resist :-). So you have effectively transformed the _problem_of_VM_shortage_
to the _someone_else's_problem_ putting it completely on the shoulders of
sysadmins. Why I have still impression that it's not the right way ?
Hmm, maybe because the cost of system administation...
Can't you still see how easilly personal swapfiles would solve it ?

Regards,
Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
