Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE5D8D0039
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 21:43:07 -0500 (EST)
Date: Fri, 4 Feb 2011 18:43:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2011-02-04-15-15 uploaded
Message-Id: <20110204184300.ebcddedb.akpm@linux-foundation.org>
In-Reply-To: <20110205133450.0204834f.sfr@canb.auug.org.au>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
	<20110205133450.0204834f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat, 5 Feb 2011 13:34:50 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Fri, 04 Feb 2011 15:15:17 -0800 akpm@linux-foundation.org wrote:
> >
> > The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://zen-kernel.org/kernel/mmotm.git
> 
> Just an FYI (origin is the above git repo):
> 
> $ git remote update origin
> Fetching origin
> fatal: read error: Connection reset by peer
> error: Could not fetch origin

Yes, that's been dead for a while and James isn't responding to email.

> Also, I create a similar git tree myself and two of the patches would not
> import using "git am" due to missing "From:" lines:
> 
> drivers-gpio-pca953xc-add-a-mutex-to-fix-race-condition.patch
> memcg-remove-direct-page_cgroup-to-page-pointer-fix.patch

Thanks, I fixed those up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
