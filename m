Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 945CD6B016C
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 15:23:29 -0400 (EDT)
Date: Thu, 25 Aug 2011 12:23:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2011-08-24-14-08 uploaded
Message-Id: <20110825122307.face013a.akpm@linux-foundation.org>
In-Reply-To: <20110825135103.GA6431@tiehlicka.suse.cz>
References: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
	<20110825135103.GA6431@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Thu, 25 Aug 2011 15:51:03 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 24-08-11 14:09:05, Andrew Morton wrote:
> > The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> 
> I have just downloaded your tree and cannot quilt it up.

Parenthetically, there's not much point in running -mm any more:
everything which matters is copied into linux-next, so just run the
following day's -next.

There are a few things in -mm which aren't transferrrred to -next.  Some
akpm-specific pain reducers, a few patches which don't look like
they'll ever get into mainline and a great shower of debugging patches
which I accumulated over the ages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
