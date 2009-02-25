Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2016A6B00EF
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 11:58:10 -0500 (EST)
Message-ID: <49A5789E.4040600@oracle.com>
Date: Wed, 25 Feb 2009 08:58:06 -0800
From: Zach Brown <zach.brown@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
References: <20090225093629.GD22785@wotan.suse.de> <49A5750A.1080006@oracle.com> <20090225165501.GK22785@wotan.suse.de>
In-Reply-To: <20090225165501.GK22785@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Mark Fasheh <mfasheh@suse.com>, Sage Weil <sage@newdream.net>
List-ID: <linux-mm.kvack.org>


> Is ocfs2 immune to the races that get covered by this patch?

I haven't the slightest idea.

> Hmm, actually possibly we can enter page_mkwrite with the page unlocked,
> but exit with the page locked? Slightly more complex, but should save
> complexity elsewhere. Yes I think this might be the best way to go.

That sounds like it would work on first glance, yeah.  Mark will yell at
us if we've gotten it wrong ;).

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
