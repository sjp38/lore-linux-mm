Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8173E6B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:01:32 -0400 (EDT)
Date: Thu, 15 Oct 2009 23:01:29 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 4/9] swap_info: miscellaneous minor cleanups
In-Reply-To: <20091015111924.01c6b36f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910152256460.4447@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150149160.3291@sister.anvils>
 <20091015111924.01c6b36f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rafael Wysocki <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Oct 2009 01:50:54 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > Move CONFIG_MIGRATION's swapdev_block() into the main CONFIG_MIGRATION
> > block, remove extraneous whitespace and return, fix typo in a comment.
> > 
> CONFIG_HIBERNATION ?

Absolutely!  Thanks a lot for spotting that (and for reviewing all these,
so quickly).  It seems I'm confused by birds migrating for the winter :)
A 4/9 v2, correcting just that comment, will follow when I've gone
through your other suggestions.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
