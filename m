Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 00F2F8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 20:15:48 -0500 (EST)
Date: Sun, 6 Mar 2011 02:15:13 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
In-Reply-To: <1299373781.3062.374.camel@calx>
Message-ID: <alpine.LNX.2.00.1103060213110.6297@swampdragon.chaosbits.net>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>  <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>  <1299191400.2071.203.camel@dan>  <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>  <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
  <1299260164.8493.4071.camel@nimitz>  <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>  <1299262495.3062.298.camel@calx>  <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>  <1299271041.2071.1398.camel@dan>
 <AANLkTimvhHxsMCf2FX0O8VqksOa2EAMz=S_C3LQKvE60@mail.gmail.com>  <1299273034.2071.1417.camel@dan>  <alpine.LNX.2.00.1103060137410.6297@swampdragon.chaosbits.net> <1299373781.3062.374.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 5 Mar 2011, Matt Mackall wrote:

> On Sun, 2011-03-06 at 01:42 +0100, Jesper Juhl wrote:
> > On Fri, 4 Mar 2011, Dan Rosenberg wrote:
> > 
> > > On Fri, 2011-03-04 at 22:58 +0200, Pekka Enberg wrote:
> > > > On Fri, Mar 4, 2011 at 10:37 PM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > > > > This patch makes these techniques more difficult by making it hard to
> > > > > know whether the last attacker-allocated object resides before a free or
> > > > > allocated object.  Especially with vulnerabilities that only allow one
> > > > > attempt at exploitation before recovery is needed to avoid trashing too
> > > > > much heap state and causing a crash, this could go a long way.  I'd
> > > > > still argue in favor of removing the ability to know how many objects
> > > > > are used in a given slab, since randomizing objects doesn't help if you
> > > > > know every object is allocated.
> > > > 
> > > > So if the attacker knows every object is allocated, how does that help
> > > > if we're randomizing the initial freelist?
> > > 
> > > If you know you've got a slab completely full of your objects, then it
> > > doesn't matter that they happened to be allocated in a random fashion -
> > > they're still all allocated, and by freeing one of them and
> > > reallocating, you'll still be next to your target.
> > > 
> > 
> > But still, if randomizing allocations makes life just a little harder for 
> > attackers in some scenarios, why not just do it?
> 
> Lemme guess, you work for the TSA?
> 
No. And now I actually feel slightly insulted.


> As far as I can tell neither of the patches under discussion do anything
> that couldn't be worked around by an exploit writer in the time it takes
> to write this email. And the second attacker, of course, will have even
> less trouble.
> 
> Putting trivial obstacles in the way of attackers accomplishes little
> beyond annoying users.
> 
If we annoy users I agree we shouldn't. If we don't annoy users (and don't 
impact performance in any relevant way) then even trivial obstacles that 
stop just a few exploits are worth it IMHO.


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
