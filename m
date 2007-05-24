Date: Thu, 24 May 2007 01:15:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] limit print_fatal_signal() rate (was: [RFC] log
 out-of-virtual-memory events)
Message-Id: <20070524011551.3d72a6e8.akpm@linux-foundation.org>
In-Reply-To: <20070524075835.GC21138@elte.hu>
References: <E1Hp5PV-0001Bn-00@calista.eckenfels.net>
	<464ED258.2010903@users.sourceforge.net>
	<20070520203123.5cde3224.akpm@linux-foundation.org>
	<20070524075835.GC21138@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: righiandr@users.sourceforge.net, Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007 09:58:35 +0200 Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Well OK.  But vdso-print-fatal-signals.patch is designated 
> > not-for-mainline anyway.
> 
> btw., why?

err, because that's what I decided a year ago.  I wonder why ;)

Perhaps because of the DoS thing, but it has a /proc knob and defaults to
off, so it should be OK.

> It's very, very useful to distro, early-boot-userspace and 
> glibc development. The only add-on change should be to not print SIGKILL 
> events. Otherwise it's very much a keeper. Hm?
> 

<promotes it>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
