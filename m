Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 940846B006E
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 19:45:26 -0500 (EST)
Date: Tue, 8 Nov 2011 00:46:15 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
Message-ID: <20111108004615.39477beb@lxorguk.ukuu.org.uk>
In-Reply-To: <20111108002520.GB25769@tango.0pointer.de>
References: <1320614101.3226.5.camel@offbook>
	<20111107112952.GB25130@tango.0pointer.de>
	<1320675607.2330.0.camel@offworld>
	<20111107135823.3a7cdc53@lxorguk.ukuu.org.uk>
	<CAPXgP117Wkgvf1kDukjWt9yOye8xArpyX29xx36NT++s8TS5Rw@mail.gmail.com>
	<20111107225314.0e3976a6@lxorguk.ukuu.org.uk>
	<20111107230712.GA25769@tango.0pointer.de>
	<20111107234337.1dc9d612@lxorguk.ukuu.org.uk>
	<20111108002520.GB25769@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Davidlohr Bueso <dave@gnu.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> And half of the other resource limits are "oddities" too?
> For  example RLIMIT_SIGPENDING is per-user and so is RLIMIT_MSGQUEUE,
> and others too.

When you look at the standards - yes.

> > And the standards have no idea how a resource limit hit for an fs would
> > be reported, nor how an app installer would check for it. Quota on the
> > other hand is defined behaviour.
> 
> EDQUOT is POSIX, but afaik there is no POSIX standardized API for quota,
> is there? i.e. the reporting of the user hitting quota is defined, but

Its part of Unix and its well defined and used by applications, both for
hitting quota (the easy bit), checking quota (when checking space for
things particularly), and manipulating them

The latter bit is nice, it means you can mount with a user quota set in
the mount options, and if you want then use quota tools to change the
quota of a specific user or two that have special rules.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
