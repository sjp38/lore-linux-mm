Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BE366004A5
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 04:50:56 -0500 (EST)
Date: Thu, 4 Feb 2010 10:50:50 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: Improving OOM killer
In-Reply-To: <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
Message-ID: <alpine.LNX.2.00.1002041044080.15395@pobox.suse.cz>
References: <201002012302.37380.l.lunak@suse.cz> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, David Rientjes wrote:

> > > 		/* Forkbombs get penalized 10% of available RAM */
> > > 		if (forkcount > 500)
> > > 			points += 100;
> > 
> >  As far as I'm concerned, this is a huge improvement over the current code 
> > (and, incidentally :), quite close to what I originally wanted). I'd be 
> > willing to test it in few real-world desktop cases if you provide a patch.
[ ... ]
> Do you have any comments about the forkbomb detector or its threshold that 
> I've put in my heuristic?  I think detecting these scenarios is still an 
> important issue that we need to address instead of simply removing it from 
> consideration entirely.

Why does OOM killer care about forkbombs *at all*?

If we really want kernel to detect forkbombs (*), we'd have to establish 
completely separate infrastructure for that (with its own knobs for tuning 
and possibilities of disabling it completely).

The task of OOM killer is to find the process that caused the system 
to run out of memory, and wipe it, it's as simple as that.

The connection to forkbombs seems to be so loose that I don't see it.

(*) How is forkbomb even defined? Where does the magic constant in 
'forkcount > 500' come from? If your aim is to penalize server processes 
on very loaded web/database servers, then this is probably correct 
aproach. Otherwise, I don't seem to see the point.

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
