Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3888D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 08:20:05 -0500 (EST)
Date: Sun, 6 Mar 2011 13:19:55 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
Message-ID: <20110306131955.722d9bd5@lxorguk.ukuu.org.uk>
In-Reply-To: <20110305162508.GA11120@thunk.org>
References: <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	<1299270709.3062.313.camel@calx>
	<1299271377.2071.1406.camel@dan>
	<AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
	<1299272907.2071.1415.camel@dan>
	<AANLkTina+O77BFV+7mO9fX2aJimpO0ov_MKwxGtMwqG+@mail.gmail.com>
	<1299275042.2071.1422.camel@dan>
	<AANLkTikA=88EMs8RRm0RPQ+Q9nKj=2G+G86h5nCnV7Se@mail.gmail.com>
	<AANLkTikQxOgYFLbc2KbEKgRYL1RCnkPE-T80-GBY2Cgj@mail.gmail.com>
	<1299279756.3062.361.camel@calx>
	<20110305162508.GA11120@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ted Ts'o <tytso@mit.edu>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@kernel.org>, Dan Rosenberg <drosenberg@vsecurity.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

> If we had wrappers for the most common cases, then any cases that were
> left that used copy_from_user() explicitly could be flagged and
> checked by hand, since they would be exception, and not the rule.

Arjan's copy_from_user validation code already does verification checks
on the copies using gcc magic.

Some of the others might be useful - kmalloc_from_user() is a fairly
obvious interface, a copy_from_user_into() interface where you pass
the destination object and its actual length as well is mostly covered by
Arjan's stuff.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
