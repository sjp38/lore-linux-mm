Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 029856B00E0
	for <linux-mm@kvack.org>; Sat, 30 May 2009 13:35:27 -0400 (EDT)
Date: Sat, 30 May 2009 10:33:36 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [patch 3/5] Apply the PG_sensitive flag to audit subsystem
Message-ID: <20090530173336.GG6535@oblivion.subreption.com>
References: <20090520185005.GC10756@oblivion.subreption.com> <alpine.LFD.2.01.0905301020260.3435@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0905301020260.3435@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, faith@redhat.com
List-ID: <linux-mm.kvack.org>

On 10:21 Sat 30 May     , Linus Torvalds wrote:
> 
> 
> On Wed, 20 May 2009, Larry H. wrote:
> >
> > +	if (!(gfp_mask & GFP_SENSITIVE))
> > +		gfp_mask |= GFP_SENSITIVE;
> 
> WTF?

Indeed.

> Why is this different from just "gfp_mask |= GFP_SENSITIVE;"

Blame anal retentiveness at the time of writing that. Surely the test
should be ditched. Looking back at that, I honestly think there might be a
place to plug the flag (in the caller) instead of doing that. I don't
think there are many places to do it, so this particular patch from the
set can be ditched and rewritten (if you want to take the selective
clearing road...)

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
