Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DB41C6B0087
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 17:02:07 -0400 (EDT)
Date: Mon, 11 Oct 2010 14:00:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Message-Id: <20101011140039.15a2c78d.akpm@linux-foundation.org>
In-Reply-To: <20101011143022.GD30667@csn.ul.ie>
References: <20101009095718.1775.qmail@kosh.dhis.org>
	<20101011143022.GD30667@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: pacman@kosh.dhis.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

(cc linuxppc-dev@lists.ozlabs.org)

On Mon, 11 Oct 2010 15:30:22 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Sat, Oct 09, 2010 at 04:57:18AM -0500, pacman@kosh.dhis.org wrote:
> > (What a big Cc: list... scripts/get_maintainer.pl made me do it.)
> > 
> > This will be a long story with a weak conclusion, sorry about that, but it's
> > been a long bug-hunt.
> > 
> > With recent kernels I've seen a bug that appears to corrupt random 4-byte
> > chunks of memory. It's not easy to reproduce. It seems to happen only once
> > per boot, pretty quickly after userspace has gotten started, and sometimes it
> > doesn't happen at all.
> > 
> 
> A corruption of 4 bytes could be consistent with a pointer value being
> written to an incorrect location.

It's corruption of user memory, which is unusual.  I'd be wondering if
there was a pre-existing bug which 6dda9d55bf545013597 has exposed -
previously the corruption was hitting something harmless.  Something
like a missed CPU cache writeback or invalidate operation.

How sensitive/vulnerable is PPC32 to such things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
