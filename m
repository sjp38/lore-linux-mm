Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC2B900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:56:48 -0400 (EDT)
Date: Wed, 22 Jun 2011 20:56:45 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110622185645.GH3263@one.firstfloor.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org> <20110622182445.GG3263@one.firstfloor.org> <20110622113851.471f116f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110622113851.471f116f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

> If something can be grafted on later then that's of course all good.  I
> do think we should have some sort of plan in which we work out how that
> will be done.  If we want to do it, that is.
> 
> However if we go this way then there's a risk that we'll end up with
> two different ways of configuring the feature and we'll need to

You'll always have multiple ways. Whatever magic you come up for
the google BIOS or for EFI won't help the majority of users with
old crufty legacy BIOS.

So you need a "everything included" way -- and the only straight forward
way to do that that I can see is the command line.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
