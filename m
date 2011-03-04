Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 32C8E8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 15:58:30 -0500 (EST)
Received: by gyb13 with SMTP id 13so1223680gyb.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 12:58:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299271041.2071.1398.camel@dan>
References: <1299174652.2071.12.camel@dan>
	<1299185882.3062.233.camel@calx>
	<1299186986.2071.90.camel@dan>
	<1299188667.3062.259.camel@calx>
	<1299191400.2071.203.camel@dan>
	<2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	<AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	<1299260164.8493.4071.camel@nimitz>
	<AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	<1299262495.3062.298.camel@calx>
	<AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	<1299271041.2071.1398.camel@dan>
Date: Fri, 4 Mar 2011 22:58:27 +0200
Message-ID: <AANLkTimvhHxsMCf2FX0O8VqksOa2EAMz=S_C3LQKvE60@mail.gmail.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 4, 2011 at 10:37 PM, Dan Rosenberg <drosenberg@vsecurity.com> w=
rote:
> This patch makes these techniques more difficult by making it hard to
> know whether the last attacker-allocated object resides before a free or
> allocated object. =A0Especially with vulnerabilities that only allow one
> attempt at exploitation before recovery is needed to avoid trashing too
> much heap state and causing a crash, this could go a long way. =A0I'd
> still argue in favor of removing the ability to know how many objects
> are used in a given slab, since randomizing objects doesn't help if you
> know every object is allocated.

So if the attacker knows every object is allocated, how does that help
if we're randomizing the initial freelist?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
