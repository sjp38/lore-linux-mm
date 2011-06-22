Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 892C0900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:39:08 -0400 (EDT)
Date: Wed, 22 Jun 2011 11:38:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-Id: <20110622113851.471f116f.akpm@linux-foundation.org>
In-Reply-To: <20110622182445.GG3263@one.firstfloor.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110622110034.89ee399c.akpm@linux-foundation.org>
	<20110622182445.GG3263@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On Wed, 22 Jun 2011 20:24:45 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> > So.  What are your thoughts on these issues?
> 
> Sounds orthogonal to me. You have to crawl before you walk.
> 
> A better way to pass in the data would be nice, but can be always
> added on top (e.g. some EFI environment variable) 
> 
> For a first try a command line argument is quite
> appropiate and simple enough.
> 
> A check for removing too much memory would be nice though,
> although it's just a choice between panicing early or later.
> 

If something can be grafted on later then that's of course all good.  I
do think we should have some sort of plan in which we work out how that
will be done.  If we want to do it, that is.

However if we go this way then there's a risk that we'll end up with
two different ways of configuring the feature and we'll need to
maintain the old way for ever.  That's a bad thing and we'd be better
off implementing the fancier scheme on day one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
