Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA32445
	for <linux-mm@kvack.org>; Wed, 20 Jan 1999 13:15:48 -0500
Subject: Re: Removing swap lockmap...
References: <871zksqbyq.fsf@atlas.CARNet.hr> <Pine.LNX.3.96.990119191333.900A-100000@laser.bogus> <199901201709.RAA11707@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 20 Jan 1999 19:14:27 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 20 Jan 1999 17:09:47 GMT"
Message-ID: <87ogntlsl8.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Tue, 19 Jan 1999 19:15:51 +0100 (CET), Andrea Arcangeli
> <andrea@e-mind.com> said:
> 
> > On 19 Jan 1999, Zlatko Calusic wrote:
> >> Yes, this case probably doesn't get enough testing with my current
> >> setup, so it is quite hard (for me) to prove removing lockmap is
> >> no-no. Problem is that I don't understand shm swapping very well
> 
> > Launch some time this proggy to try out shm swapping:
> 
> I have a shared memory stresser anyway if you want.  However, when we
> originally took out the lock map, it proved _very_ hard to reproduce the
> race, and only a couple of people reported problems.  Plain stress
> testing with random access patterns over a day or more did not show up
> the problem.  
> 
> These races can be very nasty and hard to trigger.  You really do need
> to think the change through rather than just try-it-and-see.
> 

Yes, after some time, I agree completely.

So I decided to take the path you're suggesting, but of course, it'll
take some time to prove anything (if at all).

Anecdote:

In fact removing swap lockmap produced very interesting situation for
me. 2.1.89 introduced the biggest improvements in MM code I saw in
2.1.x series, but also that subtle race condition which decided to
reveal itself slightly later.

At some time, let's say around 2.1.95 :), I decided to buy another
32MB of RAM, to let my Netscape and XEmacs work together more
smoothly. And there came my friend telling me he's just about to buy
128 MB of RAM, and is thus willing to give me his 2 x 16MB SIMM-s (to
make space in his computer), with adequately lower price than in the
stores. I was slightly worried that maybe he's trying to get rid of
bad SIMM-s, but eventually I agreed and made a deal (after all, what
kind of friend would he be, selling broken things to his buddy :)).

And then it started. My daemons started to dissapear misteriously (but
very rarely, once in a few days or so). Few times, while stressing the
system, X died in a horrible death taking away all my applications,
and nothing like that didn't happen for a long time before that.

So what would you think in such a situation? :)

Well, thanks to few very useful mails exchanged between you and Eric
(that appeared on the linux-mm list), my friendship was saved :), and
I understood that my problems were not due to a bad memory, but a
stubborn race condition, hard to track, and hard to reproduce as we
know now. Not to mention that it behaved much like a bad memory.

In fact, all that was a RL "race condition", testing new memory and
beta code at the same time. That's what you get living on the bleeding 
edge. :)

Sorry for spamming the list(s) with long stories like this.

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
