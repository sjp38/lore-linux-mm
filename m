Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA9E8D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 05:44:45 -0500 (EST)
Date: Sat, 5 Feb 2011 11:44:30 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2011-02-04-15-15 uploaded
Message-ID: <20110205104430.GB2315@cmpxchg.org>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
 <20110205133450.0204834f.sfr@canb.auug.org.au>
 <20110204184300.ebcddedb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110204184300.ebcddedb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Feb 04, 2011 at 06:43:00PM -0800, Andrew Morton wrote:
> On Sat, 5 Feb 2011 13:34:50 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> 
> > Hi Andrew,
> > 
> > On Fri, 04 Feb 2011 15:15:17 -0800 akpm@linux-foundation.org wrote:
> > >
> > > The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> > > 
> > > and will soon be available at
> > > 
> > >    git://zen-kernel.org/kernel/mmotm.git
> > 
> > Just an FYI (origin is the above git repo):
> > 
> > $ git remote update origin
> > Fetching origin
> > fatal: read error: Connection reset by peer
> > error: Could not fetch origin
> 
> Yes, that's been dead for a while and James isn't responding to email.

I created an automated tree for myself a while ago.  It has been
working fine for the last few -mmotm snapshots:

	http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

Feel free to use that and let me know if something is not right.

> > Also, I create a similar git tree myself and two of the patches would not
> > import using "git am" due to missing "From:" lines:

I use git-quiltimport with the --author flag to generate my tree, such
patches will fall back to

	author	   mmotm auto import <mm-commits@vger.kernel.org>

IIRC I added that for origin.patch and linux-next.patch, which never
carried From: lines.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
