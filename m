Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C42F76B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 04:17:28 -0500 (EST)
Date: Thu, 12 Feb 2009 10:17:21 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Message-ID: <20090212091721.GB1888@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090211141434.dfa1d079.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, orenl@cs.columbia.edu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 10 Feb 2009 09:05:47 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > On Tue, 2009-01-27 at 12:07 -0500, Oren Laadan wrote:
> > > Checkpoint-restart (c/r): a couple of fixes in preparation for 64bit
> > > architectures, and a couple of fixes for bugss (comments from Serge
> > > Hallyn, Sudakvev Bhattiprolu and Nathan Lynch). Updated and tested
> > > against v2.6.28.
> > > 
> > > Aiming for -mm.
> > 
> > Is there anything that we're waiting on before these can go into -mm?  I
> > think the discussion on the first few patches has died down to almost
> > nothing.  They're pretty reviewed-out.  Do they need a run in -mm?  I
> > don't think linux-next is quite appropriate since they're not _quite_
> > aimed at mainline yet.
> > 
> 
> I raised an issue a few months ago and got inconclusively waffled at. 
> Let us revisit.
> 
> I am concerned that this implementation is a bit of a toy, and that we
> don't know what a sufficiently complete implementation will look like. 
> There is a risk that if we merge the toy we either:
> 
> a) end up having to merge unacceptably-expensive-to-maintain code to
>    make it a non-toy or
> 
> b) decide not to merge the unacceptably-expensive-to-maintain code,
>    leaving us with a toy or
> 
> c) simply cannot work out how to implement the missing functionality.
> 
> 
> So perhaps we can proceed by getting you guys to fill out the following
> paperwork:
> 
> - In bullet-point form, what features are present?

It would be nice to get an honest, critical-thinking answer on this.

What is it good for right now, and what are the known weaknesses and
quirks you can think of. Declaring them upfront is a bonus - not talking
about them and us discovering them later at the patch integration stage
is a sure receipe for upstream grumpiness.

This is an absolutely major featue, touching each and every subsystem in
a very fundamental way. It is also a cool capability worth a bit of a
maintenance pain, so we'd like to see the pros and cons nicely enumerated,
to the best of your knowledge. Most of us are just as feature-happy at
heart as you folks are, so if it can be done sanely we are on your side.

For example, one of the critical corner points: can an app programmatically 
determine whether it can support checkpoint/restart safely? Are there 
warnings/signals/helpers in place that make it a well-defined space, and
make the implementation of missing features directly actionable?

( instead of: 'silent breakage' and a wishy-washy boundary between the
  working and non-working space. Without clear boundaries there's no
  clear dynamics that extends the 'working' space beyond the demo stage. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
