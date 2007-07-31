Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l6V6wWPL104058
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 06:58:32 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6V6wWtq1507376
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 08:58:32 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6V6wTcp025329
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 08:58:29 +0200
Subject: Re: [ck] Re: SD still better than CFS for 3d ?
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <b21f8390707302007n2f21018crc6b7cd83666e0f3c@mail.gmail.com>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com>
	 <20070729204716.GB1578@elte.hu>
	 <930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com>
	 <20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site>
	 <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>
	 <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com>
	 <20070730182959.GA29151@infradead.org> <adaps29sm62.fsf@cisco.com>
	 <b21f8390707302007n2f21018crc6b7cd83666e0f3c@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 31 Jul 2007 09:01:48 +0200
Message-Id: <1185865308.4561.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Roland Dreier <rdreier@cisco.com>, Christoph Hellwig <hch@infradead.org>, Jacob Braun <jwbraun@gmail.com>, kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-31 at 13:07 +1000, Matthew Hawkins wrote:
> On 7/31/07, Roland Dreier <rdreier@cisco.com> wrote:
> >  >      Fuck you Martin!
> >
> > I think you meant to yell at Matthew, not Martin ;)
> 
> What's amusing about this is he's yelling at me for something I didn't
> do, can't even get my name right, and has the audacity to claim that
> *I* am the one looking like a fool!  While we're descending into
> primary school theatrics, may I just say "takes one to know one" ;-)

Pouring oil into the fire ?

> I took the time to track down what caused a breakage - in an "illegal
> binary driver" (not against the law here, though defamation certainly
> is...) no less.  And contacted the vendor (separately).  Other people
> on desktop machines with an ATI card using the fglrx driver may have
> been interested to know that they can't do the benchmarking some
> people here on lkml and -mm are asking for with a current 2.6.23 git
> kernel, hence my post.

To inform the vendor and to post a warning about the issue on lkml was
the right thing to do. It is the wording of your post that obviously
irked some people.

> Martin's cleanup patch is good and I never claimed otherwise, I just
> said the comment on the commit was a bad call (as there are users of
> that interface).  Certainly ATI should fix their dodgy drivers.
> That's been the cry of the community for a long time...

The commit message could have been better. The correct thing to say
would have been "Nobody in the official kernel is using
ptep_test_and_clear_dirty and ptep_clear_flush_dirty."
nvidia will have to adapt their binary driver. This is not the first
time it breaks and it won't be the last time. We do not really have a
problem and we should all calm down and put that issue to rest.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
