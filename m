Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 81BE76B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 18:00:14 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Mon, 18 Jan 2010 00:00:23 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001171427.27954.rjw@sisk.pl> <1263754684.724.444.camel@pasglop>
In-Reply-To: <1263754684.724.444.camel@pasglop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001180000.23376.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Oliver Neukum <oliver@neukum.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sunday 17 January 2010, Benjamin Herrenschmidt wrote:
> On Sun, 2010-01-17 at 14:27 +0100, Rafael J. Wysocki wrote:
...
> However, it's hard to deal with the case of allocations that have
> already started waiting for IOs. It might be possible to have some VM
> hook to make them wakeup, re-evaluate the situation and get out of that
> code path but in any case it would be tricky.

In the second version of the patch I used an rwsem that made us wait for these
allocations to complete before we changed gfp_allowed_mask.

[This is kinda buggy in the version I sent, but I'm going to send an update
in a minute.]

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
