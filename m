Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F0298D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 11:40:32 -0500 (EST)
Date: Mon, 7 Mar 2011 10:40:25 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
In-Reply-To: <alpine.LNX.2.00.1103060213110.6297@swampdragon.chaosbits.net>
Message-ID: <alpine.DEB.2.00.1103071039470.1973@router.home>
References: <1299174652.2071.12.camel@dan> <1299185882.3062.233.camel@calx>  <1299186986.2071.90.camel@dan> <1299188667.3062.259.camel@calx>  <1299191400.2071.203.camel@dan>  <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>  <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
  <1299260164.8493.4071.camel@nimitz>  <AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>  <1299262495.3062.298.camel@calx>  <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>  <1299271041.2071.1398.camel@dan>
 <AANLkTimvhHxsMCf2FX0O8VqksOa2EAMz=S_C3LQKvE60@mail.gmail.com>  <1299273034.2071.1417.camel@dan>  <alpine.LNX.2.00.1103060137410.6297@swampdragon.chaosbits.net> <1299373781.3062.374.camel@calx>
 <alpine.LNX.2.00.1103060213110.6297@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Juhl <jj@chaosbits.net>
Cc: Matt Mackall <mpm@selenic.com>, Dan Rosenberg <drosenberg@vsecurity.com>, Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 6 Mar 2011, Jesper Juhl wrote:

> > Putting trivial obstacles in the way of attackers accomplishes little
> > beyond annoying users.
> >
> If we annoy users I agree we shouldn't. If we don't annoy users (and don't
> impact performance in any relevant way) then even trivial obstacles that
> stop just a few exploits are worth it IMHO.

Randomizing affects performance. The current way of initialization for the
list of free objects was chosen because the processor can do effective
prefetching when the allocator serves objects following each other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
