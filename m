Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E28306B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 01:36:12 -0400 (EDT)
Date: Thu, 25 Mar 2010 16:36:08 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: lockdep page lock
Message-ID: <20100325053608.GB7493@laptop.nomadix.com>
References: <20100315155859.GE2869@laptop>
 <20100315180759.GA7744@quack.suse.cz>
 <20100316022153.GJ2869@laptop>
 <1269437291.5109.238.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269437291.5109.238.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 02:28:11PM +0100, Peter Zijlstra wrote:
> On Tue, 2010-03-16 at 13:21 +1100, Nick Piggin wrote:
> > 
> > 
> > Agreed (btw. Peter is there any way to turn lock debugging back on?
> > it's annoying when cpufreq hotplug code or something early breaks and
> > you have to reboot in order to do any testing).
> 
> Not really, the only way to do that is to get the full system back into
> a known (zero) lock state and then fully reset the lockdep state.
> 
> It might be possible using the freezer, but I haven't really looked at
> that, its usually simpler to simply fix the offending code or simply not
> build it in your kernel.

Right, but sometimes that is not possible (or you don't want to
turn off cpufreq). I guess you could have an option to NOT turn
it off in the first place. You could just turn off warnings, but
leave everything else running, couldn't you?

And then the option would just be to turn the printing back on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
