Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B48906B002D
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 20:50:39 -0400 (EDT)
Date: Thu, 3 Nov 2011 17:54:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-Id: <20111103175410.b15efb8c.akpm@linux-foundation.org>
In-Reply-To: <4EB2D427020000780005ED64@nat28.tlf.novell.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<4EB2D427020000780005ED64@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Neo Jia <cyclonusj@gmail.com>, levinsasha928@gmail.com, JeremyFitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, ngupta@vflare.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 03 Nov 2011 16:49:27 +0000 "Jan Beulich" <JBeulich@suse.com> wrote:

> >>> On 27.10.11 at 20:52, Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
> > Hi Linus --
> > 
> > Frontswap now has FOUR users: Two already merged in-tree (zcache
> > and Xen) and two still in development but in public git trees
> > (RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
> > changes required to support transcendent memory; part 1 was cleancache
> > which you merged at 3.0 (and which now has FIVE users).
> > 
> > Frontswap patches have been in linux-next since June 3 (with zero
> > changes since Sep 22).  First posted to lkml in June 2009, frontswap 
> > is now at version 11 and has incorporated feedback from a wide range
> > of kernel developers.  For a good overview, see
> >    http://lwn.net/Articles/454795.
> > If further rationale is needed, please see the end of this email
> > for more info.
> > 
> > SO... Please pull:
> > 
> > git://oss.oracle.com/git/djm/tmem.git #tmem
> > 
> >...
> > Linux kernel distros incorporating frontswap:
> > - Oracle UEK 2.6.39 Beta:
> >    http://oss.oracle.com/git/?p=linux-2.6-unbreakable-beta.git;a=summary 
> > - OpenSuSE since 11.2 (2009) [see mm/tmem-xen.c]
> >    http://kernel.opensuse.org/cgit/kernel/ 
> 
> I've been away so I am too far behind to read this entire
> very long thread, but wanted to confirm that we've been
> carrying an earlier version of this code as indicated above
> and it would simplify our kernel maintenance if frontswap
> got merged.  So please count me as supporting frontswap.

Are you able to tell use *why* you're carrying it, and what benefit it
is providing to your users?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
