Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47AD96B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:48:40 -0400 (EDT)
Date: Tue, 24 May 2011 15:48:39 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: (Short?) merge window reminder
Message-ID: <20110524144839.GC30117@linux-mips.org>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com>
 <20110523192056.GC23629@elte.hu>
 <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>
 <20110523231721.GM10009@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110523231721.GM10009@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ted Ts'o <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On Mon, May 23, 2011 at 07:17:21PM -0400, Ted Ts'o wrote:

> > So I'm toying with 3.0 (and in that case, it really would be "3.0",
> > not "3.0.0" - the stable team would get the third digit rather than
> > the fourth one.
> 
> If we change from 2.6.X to 3.X, then if we don't change anything else,
> then successive stable release will cause the LINUX_VERSION_CODE to be
> incremented.  This isn't necessary bad, but it would be a different
> from what we have now.

It will require another bunch of changes to scripts that try to make sense
out of kernel Linux version numbers.  It's a minor issue and we might be
better off doing something else than version number magic.  Not last a
new major version number raises expectations - whatever those might be.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
