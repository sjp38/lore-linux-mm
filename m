Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8898D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 16:44:08 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dan Rosenberg <drosenberg@vsecurity.com>
In-Reply-To: <AANLkTina+O77BFV+7mO9fX2aJimpO0ov_MKwxGtMwqG+@mail.gmail.com>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>
	 <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>
	 <1299191400.2071.203.camel@dan>
	 <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	 <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	 <1299260164.8493.4071.camel@nimitz>
	 <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	 <1299262495.3062.298.camel@calx>
	 <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	 <1299270709.3062.313.camel@calx> <1299271377.2071.1406.camel@dan>
	 <AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
	 <1299272907.2071.1415.camel@dan>
	 <AANLkTina+O77BFV+7mO9fX2aJimpO0ov_MKwxGtMwqG+@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 16:44:02 -0500
Message-ID: <1299275042.2071.1422.camel@dan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 23:30 +0200, Pekka Enberg wrote:
> Right. So you fill a slab with objects A that you want to overflow
> (struct shmid_kernel in the example exploit) then free one of them,
> allocate object B, smash it (and the next object), and find the
> smashed object A.
> 
> But doesn't that make the whole /slab/procinfo discussion moot? You
> can always use brute force to allocate N objects (where N is larger
> than max objects in a slab) and then just free nth object that's most
> likely to land on the slab you have full control over (as explained by
> Matt).
> 
>                         Pekka 

This is a good point, and one that I've come to accept as a result of
having this conversation.  Consider the patch dropped, unless there are
other reasons I've missed.  I still think it's worth brainstorming
techniques for hardening the kernel heap in ways that don't create
performance impact, but I admit that the presence or absence of this
debugging information isn't a crucial factor in successful exploitation.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
