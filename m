Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC406B00F1
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 12:02:44 -0500 (EST)
Date: Wed, 25 Feb 2009 18:02:40 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090225170240.GL22785@wotan.suse.de>
References: <20090225093629.GD22785@wotan.suse.de> <49A5750A.1080006@oracle.com> <20090225165501.GK22785@wotan.suse.de> <49A5789E.4040600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49A5789E.4040600@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Zach Brown <zach.brown@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Mark Fasheh <mfasheh@suse.com>, Sage Weil <sage@newdream.net>
List-ID: <linux-mm.kvack.org>

(Chris, your point about lock ordering is good. Zach raised the
same one. Thanks for the good catch there guys).

On Wed, Feb 25, 2009 at 08:58:06AM -0800, Zach Brown wrote:
> 
> > Is ocfs2 immune to the races that get covered by this patch?
> 
> I haven't the slightest idea.

Well, they would be covered with the new scheme anyway:

 
> > Hmm, actually possibly we can enter page_mkwrite with the page unlocked,
> > but exit with the page locked? Slightly more complex, but should save
> > complexity elsewhere. Yes I think this might be the best way to go.
> 
> That sounds like it would work on first glance, yeah.  Mark will yell at
> us if we've gotten it wrong ;).

OK, thanks. I'll go with that approach and see what happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
