Received: by nf-out-0910.google.com with SMTP id h3so23039nfh
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 19:35:18 -0700 (PDT)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
Date: Thu, 26 Jul 2007 04:32:52 +0200
References: <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <a781481a0707251033t5b95cde7k620810bcc0b98c1@mail.gmail.com> <20070725203523.GA10750@elte.hu>
In-Reply-To: <20070725203523.GA10750@elte.hu>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200707260432.52739.bzolnier@gmail.com>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Satyam Sharma <satyam.sharma@gmail.com>, Rene Herman <rene.herman@gmail.com>, Jos Poortvliet <jos@mijnkamer.nl>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

Some general thoughts about submitter/maintainer responsibilities,
not necessarily connected with the recents events (I hasn't been
following them closely - some people don't have that much free time
to burn at their hands ;)...

On Wednesday 25 July 2007, Ingo Molnar wrote:
> 
> * Satyam Sharma <satyam.sharma@gmail.com> wrote:
> 
> > > concentrate on making sure that both you and the maintainer 
> > > understands the problem correctly,
> > 
> > This itself may require some "convincing" to do. What if the 
> > maintainer just doesn't recognize the problem? Note that the 
> > development model here is more about the "social" thing than purely a 
> > "technical" thing. People do handwave, possibly due to innocent 
> > misunderstandings, possibly without. Often it's just a case of seeing 
> > different reasons behind the "problematic behaviour". Or it could be a 
> > case of all of the above.
> 
> sure - but i was really not talking about from the user's perspective, 
> but from the enterprising kernel developer's perspective who'd like to 
> solve a particular problem. And the nice thing about concentrating on 
> the problem: if you do that well, it does not really matter what the 
> maintainer thinks!

Yes, this is a really good strategy to get you changes upstream (and it
works) - just make changes so perfect that nobody can really complain. :)

The only problem is that the bigger the change becomes the less likely it
is to get it perfect so for really big changes it is also useful to show
maintainer that you take responsibility of your changes (by taking bugreports
and potential review issues very seriously instead of ignoring them, past
history of your merged changes has also a big influence here) so he will
know that you won't leave him in the cold with your code when bugreports
happen and be _sure_ that they will happen with bigger changes.

> ( Talking to the maintainer can of course be of enormous help in the 
>   quest for understanding the problem and figuring out the best fix - 
>   the maintainer will most likely know more about the subject than 
>   yourself. More communication never hurts. It's an additional bonus if 
>   you manage to convince the maintainer to take up the matter for 
>   himself. It's not a given right though - a maintainer's main task is 
>   to judge code that is being submitted, to keep a subsystem running
>   smoothly and to not let it regress - but otherwise there can easily be
>   different priorities of what tasks to tackle first, and in that sense 
>   the maintainer is just one of the many overworked kernel developers 
>   who has no real obligation what to tackle first. )

Yep, and patch author should try to help maintainer understand both the
problem he is trying to fix and the solution, i.e. throwing some undocumented
patches and screaming at maintainer to merge them is not a way to go.

> If the maintainer rejects something despite it being well-reasoned, 
> well-researched and robustly implemented with no tradeoffs and 
> maintainance problems at all then it's a bad maintainer. (but from all 
> i've seen in the past few years the VM maintainers do their job pretty 
> damn fine.) And note that i _do_ disagree with them in this particular 
> swap-prefetch case, but still, the non-merging of swap-prefetch was not 
> a final decision at all. It was more of a "hm, dunno, i still dont 
> really like it - shouldnt this be done differently? Could we debug this 
> a bit better?" reaction. Yes, it can be frustrating after more than one 
> year.
> 
> > > possibly write some testcase that clearly exposes it, and
> > 
> > Oh yes -- that'll be helpful, but definitely not necessarily a 
> > prerequisite for all issues, and then you can't even expect everybody 
> > to write or test/benchmark with testcases. (oh, btw, this is assuming 
> > you do find consensus on a testcase)
> 
> no, but Con is/was certainly more than capable to write testcases and to 
> debug various scenarios. That's the way how new maintainers are found 
> within Linux: people take matters in their own hands and improve a 
> subsystem so that they'll either peacefully co-work with the other 
> maintainers or they replace them (sometimes not so peacefully - like in 
> the IDE/SATA/PATA saga).

Heh, now that you've raised IDE saga I feel obligated to stand up
and say a few words...

The latest opening of IDE saga was quite interesting in the current context
because we had exactly the reversed situation there - "independent" maintainer
and "enterprise" developer (imagine the amount of frustration on both sides)
but the root source was quite similar (inability to get changes merged).

IMO the source root of the conflict lied in coming from different perspectives
and having a bit different priorities (stabilising/cleaning current code vs
adding new features on top of pile of crap).  In such situations it is very
important to be able to stop for a moment and look at the situation from
the other person's perspective.

In summary:

The IDE-wars are the thing of the past and lets learn from IDE-world
mistakes instead of repeating them in other subsystems, OK? :)

> > > help the maintainer debug the problem.
> > 
> > Umm ... well. Should this "dance-with-the-maintainer" and all be 
> > really necessary? What you're saying is easy if a "bug" is simple and 
> > objective, with mathematically few (probably just one) possible 
> > correct solutions. Often (most often, in fact) it's a subjective issue 
> > -- could be about APIs, high level design, tradeoffs, even little 
> > implementation nits ... with one person wanting to do it one way, 
> > another thinks there's something hacky or "band-aidy" about it and a 
> > more beautiful/elegant solution exists elsewhere. I think there's a 
> > similar deadlock here (?)
> 
> you dont _have to_ cooperative with the maintainer, but it's certainly 
> useful to work with good maintainers, if your goal is to improve Linux. 
> Or if for some reason communication is not working out fine then grow 
> into the job and replace the maintainer by doing a better job.

The idea of growing into the job and replacing the maintainer by proving
the you are doing better job was viable few years ago but may not be
feasible today.

If maintainer is "enterprise" developer and maintaining is part of his
job replacing him may be not possible et all because you simply lack
the time to do the job.  You may be actually better but you can't afford
to show it and without showing it you won't replace him (catch 22).

Oh, and it could happen that if maintainer works for a distro he sticks
his competing solution to the problem to the distro kernel and suddenly
gets order of magnitude more testers and sometimes even contributors.

How are you supposed to win such competition?  [ A: You can't. ]

I'm not even mentioning the situation when the maintainer is just a genius
and one of the best kernel hackers ever (I'm talking about you actually :)
so your chances are pretty slim from the start...

> > > _Optionally_, if you find joy in it, you are also free to write a 
> > > proposed solution for that problem
> > 
> > Oh yes. But why "optionally"? This is *precisely* what the spirit of 
> > development in such open / distributed projects is ... unless Linux 
> > wants to die the same, slow, ivory-towered, miserable death that *BSD 
> > have.
> 
> perhaps you misunderstood how i meant the 'optional': it is certainly 
> not required to write a solution for every problem you are reporting. 
> Best-case the maintainer picks the issue up and solves it. Worst-case 
> you get ignored. But you always have the option to take matters into 
> your own hands and solve the problem.
> 
> > >and submit it to the maintainer.
> > 
> > Umm, ok ... pretty unlikely Linus or Andrew would take patches for any 
> > kernel subsystem (that isn't obvious/trivial) from anybody just like 
> > that, so you do need to Cc: the ones they trust (maintainer) to ensure 
> > they review/ack your work and pick it up.
> 
> actually, it happens pretty frequently, and NACK-ing perfectly 

It actually happens really rarely (there are pretty good reasons for that).

> reasonable patches is a sure way towards getting replaced as a 
> maintainer.

"reasonable" is highly subjective

> > > is the wrong way around. It might still work out fine if the 
> > > solution is correct (especially if the patch is small and obvious), 
> > > but if there are any non-trivial tradeoffs involved, or if 
> > > nontrivial amount of code is involved, you might see your patch at 
> > > the end of a really long (and constantly growing) waiting list of 
> > > patches.
> > 
> > That's the whole point. For non-trivial / non-obvious / subjective 
> > issues, the "process" you laid out above could itself become a problem 
> > ...
> 
> firstly, there's rarely any 'subjective' issue in maintainance 
> decisions, even when it comes to complex patches. The 'subjective' issue 
> becomes a factor mostly when a problem has not been researched well 
> enough, when it becomes more of a faith thing ('i believe it helps me') 
> than a fully fact-backed argument. Maintainers tend to dodge such issues 
> until they become more clearly fact-backed.

Yep.

However there is a some reasonable time limit for this dodging, two years
isn't reasonable.  By being a maintainer you frequently have to sacrifice
your own goals and instead work on other people changes first (sometimes
even on changes that you don't find particulary interesting or important).
Sure it doesn't give you the same credit you'll get for your own changes
but you're investing in people who will help you in a long-term.

Could you allow the luxury of losing these people?

The another problem is that sometimes it seems that independent developers
has to go through more hops than entreprise ones and it is really frustrating
experience for them.  There is no conspiracy here - it is only the natural
mechanism of trusting more in the code of people who you are working with more.

> providing more and more facts gradually reduces the 'judgement/taste' 
> leeway of maintainers, down to an almost algorithmic level.
> but in any case there's always the ultimate way out: prove that you can 
> do a better job yourself and replace the maintainer. But providing an 

As stated before - this is nearly impossible in some cases.

I'm not proposing any kind of justice or fair chances here I'm just saying
that in the long-term it is gonna hurt said maintainer because he will lose
talented people willing to work on the code that he maintains.

> overwhelming, irresistable body of facts in favor of a patch does the 
> trick too in 99.9% of the cases.

Now could I ask people to stop all this -ck threads and give the developers
involved in the recent events some time to calmly rethink the whole case.

Please?

Thanks,
Bart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
