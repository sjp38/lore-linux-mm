Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 63AA66B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 20:05:08 -0400 (EDT)
Subject: Re: What can OpenVZ do?
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz> <20090213102732.GB4608@elte.hu>
	<20090213113248.GA15275@x200.localdomain>
	<20090213114503.GG15679@elte.hu>
	<20090213222818.GA17630@x200.localdomain>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 13 Mar 2009 17:04:55 -0700
In-Reply-To: <20090213222818.GA17630@x200.localdomain> (Alexey Dobriyan's message of "Sat\, 14 Feb 2009 01\:28\:18 +0300")
Message-ID: <m1wsatrmu0.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Alexey Dobriyan <adobriyan@gmail.com> writes:

> On Fri, Feb 13, 2009 at 12:45:03PM +0100, Ingo Molnar wrote:
>> 
>> * Alexey Dobriyan <adobriyan@gmail.com> wrote:
>> 
>> > On Fri, Feb 13, 2009 at 11:27:32AM +0100, Ingo Molnar wrote:
>> > > Merging checkpoints instead might give them the incentive to get
>> > > their act together.
>> > 
>> > Knowing how much time it takes to beat CPT back into usable shape every time
>> > big kernel rebase is done, OpenVZ/Virtuozzo have every single damn incentive
>> > to have CPT mainlined.
>> 
>> So where is the bottleneck? I suspect the effort in having forward ported
>> it across 4 major kernel releases in a single year is already larger than
>> the technical effort it would  take to upstream it. Any unreasonable upstream 
>> resistence/passivity you are bumping into?
>
> People were busy with netns/containers stuff and OpenVZ/Virtuozzo bugs.

Yes.  Getting the namespaces particularly the network namespace finished
has consumed a lot of work.

Then we have a bunch of people helping with ill conceived patches that seem
to wear out the patience of people upstream.  Al, Greg kh, Linus.

The whole recent ressurection of the question of we should have a clone
with pid syscall.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
