Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C59D98D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 15:32:07 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>
	 <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	 <1299260164.8493.4071.camel@nimitz>
	 <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	 <1299262495.3062.298.camel@calx>
	 <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 14:31:49 -0600
Message-ID: <1299270709.3062.313.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, Dan Rosenberg <drosenberg@vsecurity.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 22:02 +0200, Pekka Enberg wrote:
> On Fri, Mar 4, 2011 at 8:14 PM, Matt Mackall <mpm@selenic.com> wrote:
> >> Of course, as you say, '/proc/meminfo' still does give you the trigger
> >> for "oh, now somebody actually allocated a new page". That's totally
> >> independent of slabinfo, though (and knowing the number of active
> >> slabs would neither help nor hurt somebody who uses meminfo - you
> >> might as well allocate new sockets in a loop, and use _only_ meminfo
> >> to see when that allocated a new page).
> >
> > I think lying to the user is much worse than changing the permissions.
> > The cost of the resulting confusion is WAY higher.
> 
> Yeah, maybe. I've attached a proof of concept patch that attempts to
> randomize object layout in individual slabs. I'm don't completely
> understand the attack vector so I don't make any claims if the patch
> helps or not.

In general, the attack relies on getting an object A (vulnerable to
overrun) immediately beneath an object B (that can be exploited when
overrun).

I'm not sure how much randomization helps, though. Allocate 1000 objects
of type B, deallocate the 800th, then allocate an object of type A. It's
almost certainly next to a B.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
