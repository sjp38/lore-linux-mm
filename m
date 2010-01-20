Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3DD6F6B007E
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:12:40 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Wed, 20 Jan 2010 22:13:23 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001192137.35232.rjw@sisk.pl> <201001201505.41167.oliver@neukum.org>
In-Reply-To: <201001201505.41167.oliver@neukum.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001202213.23373.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Oliver Neukum <oliver@neukum.org>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 20 January 2010, Oliver Neukum wrote:
> Am Dienstag, 19. Januar 2010 21:37:35 schrieb Rafael J. Wysocki:
> > That said, Maxim reported that in his test case the mm subsystem apparently
> > attempted to use I/O even if there was a plenty of free memory available and
> > I'd like prevent that from happening.
> 
> Hi,
> 
> it seems to me that this is caused by the mm subsytem maintaing
> a share of clean pages precisely so that GFP_NOIO will work.
> Perhaps it is a good idea to
> a) launder a number of pages if the system is about to be suspended
> between the freezer and notifying drivers

That was tried, didn't work.

> b) set the ration of clean pages to dirty pages to 0 while suspending
> the system.

Patch, please?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
