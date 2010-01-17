Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C81E36B0047
	for <linux-mm@kvack.org>; Sat, 16 Jan 2010 20:23:54 -0500 (EST)
From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Sun, 17 Jan 2010 02:24:35 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001162317.39940.rjw@sisk.pl> <201001170138.37283.rjw@sisk.pl>
In-Reply-To: <201001170138.37283.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001170224.36267.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Am Sonntag, 17. Januar 2010 01:38:37 schrieb Rafael J. Wysocki:
> > Now having said that, we've been considering a change that will turn all
> > GFP_KERNEL allocations into GFP_NOIO during suspend/resume, so perhaps I'll
> > prepare a patch to do that and let's see what people think.
> 
> If I didn't confuse anything (which is likely, because it's a bit late here
> now), the patch below should do the trick.  I have only checked that it doesn't
> break compilation, so please take it with a grain of salt.
> 
> Comments welcome.

I think this is a bad idea as it makes the mm subsystem behave differently
in the runtime and in the whole system cases. What's so hard about telling
people that they need to use GFP_NOIO in suspend() and resume()?

		Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
