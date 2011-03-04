Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFEA8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 01:52:06 -0500 (EST)
Received: by gwj15 with SMTP id 15so940497gwj.8
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 22:52:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
References: <1299174652.2071.12.camel@dan>
	<1299185882.3062.233.camel@calx>
	<1299186986.2071.90.camel@dan>
	<1299188667.3062.259.camel@calx>
	<1299191400.2071.203.camel@dan>
	<2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
Date: Fri, 4 Mar 2011 08:52:04 +0200
Message-ID: <AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, Matt Mackall <mpm@selenic.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mar 3, 2011, at 5:30 PM, Dan Rosenberg wrote:
>> I appreciate your input on this, you've made very reasonable points.
>> I'm just not convinced that those few real users are being substantially
>> inconvenienced, even if there's only a small benefit for the larger
>> population of users who are at risk for attacks. =A0Perhaps others could
>> contribute their opinions to the discussion.

On Fri, Mar 4, 2011 at 2:50 AM, Theodore Tso <tytso@mit.edu> wrote:
> Being able to monitor /proc/slabinfo is incredibly useful for finding var=
ious
> kernel problems. =A0We can see if some part of the kernel is out of balan=
ce,
> and we can also find memory leaks. =A0 I once saved a school system's Lin=
ux
> deployment because their systems were crashing once a week, and becoming
> progressively more unreliable before they crashed, and the school board
> was about to pull the plug.

Indeed. However, I'm not sure we need to expose the number of _active
objects_ to non-CAP_ADMIN users (which could be set to zeros if you
don't have sufficient privileges). Memory leaks can be detected from
the total number of objects anyway, no?

On Fri, Mar 4, 2011 at 2:50 AM, Theodore Tso <tytso@mit.edu> wrote:
> I wonder if there is some other change we could make to the slab allocato=
r
> that would make it harder for exploit writers without having to protect t=
he
> /proc/slabinfo file. =A0For example, could we randomly select different f=
ree
> objects in a page instead of filling them in sequentially?

We can do something like that if we can live with the performance costs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
