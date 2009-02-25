Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2C06B00FD
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 17:35:40 -0500 (EST)
Date: Wed, 25 Feb 2009 14:35:35 -0800
From: Mark Fasheh <mfasheh@suse.com>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090225223535.GT17410@wotan.suse.de>
Reply-To: Mark Fasheh <mfasheh@suse.com>
References: <20090225093629.GD22785@wotan.suse.de> <49A5750A.1080006@oracle.com> <20090225165501.GK22785@wotan.suse.de> <49A5789E.4040600@oracle.com> <20090225170240.GL22785@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090225170240.GL22785@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Zach Brown <zach.brown@oracle.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Sage Weil <sage@newdream.net>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 06:02:40PM +0100, Nick Piggin wrote:
> > > Hmm, actually possibly we can enter page_mkwrite with the page unlocked,
> > > but exit with the page locked? Slightly more complex, but should save
> > > complexity elsewhere. Yes I think this might be the best way to go.
> > 
> > That sounds like it would work on first glance, yeah.  Mark will yell at
> > us if we've gotten it wrong ;).
> 
> OK, thanks. I'll go with that approach and see what happens.

Yeah, that sounds reasonable... Thanks for pointing this out Zach!
	--Mark

--
Mark Fasheh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
