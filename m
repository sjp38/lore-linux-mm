Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBA155F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:23:09 -0400 (EDT)
Date: Wed, 8 Apr 2009 00:25:43 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [5/16] POISON: Add support for poison swap entries
Message-ID: <20090407222543.GB17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151002.0AA8F1D046E@basil.firstfloor.org> <alpine.DEB.1.10.0904071710500.12192@qirst.com> <20090407215605.GZ17934@one.firstfloor.org> <alpine.DEB.1.10.0904071755200.12192@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904071755200.12192@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 05:56:28PM -0400, Christoph Lameter wrote:
> On Tue, 7 Apr 2009, Andi Kleen wrote:
> 
> > On Tue, Apr 07, 2009 at 05:11:26PM -0400, Christoph Lameter wrote:
> > >
> > > Could you separate the semantic changes to flag checking for migration
> >
> > You mean to try_to_unmap?
> 
> I mean the changes to checking the pte contents for a migratable /
> swappable page. Those are significant independent from this patchset and
> would be useful to review independently.

Sorry I'm still not quite sure what you're asking for.

Are you asking about the fault path or about try_to_unmap or some
other path?

And why do you want a separate patchset versus merely a separate patch?
(afaik the patches to generic code are already pretty separated)

I don't really change the semantics of the migration or swap code itself
for example. At least not consciously. If I did that would be a bug.

e.g. the changes to try_to_unmap are two stages:
- add flags/action code. Everything should still do the same, just
the flags are passed around differently.
- add a check for an already poisoned page and insert a poison
swap entry for those

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
