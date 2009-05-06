Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 88FBF6B005D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 13:09:15 -0400 (EDT)
Date: Wed, 6 May 2009 10:09:17 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506170917.GE15712@x200.localdomain>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <4A01AC5E.6000906@redhat.com> <20090506161424.GC15712@x200.localdomain> <Pine.LNX.4.64.0905061732220.5775@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905061732220.5775@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Chris Wright <chrisw@redhat.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Hugh Dickins (hugh@veritas.com) wrote:
> On Wed, 6 May 2009, Chris Wright wrote:
> > Another
> > question of what to do w/ VM_LOCKED, should that exclude VM_MERGE or
> > let user get what asked for?
> 
> What's the issue with VM_LOCKED?  We wouldn't want to merge a page
> while it was under get_user_pages (unless KSM's own, but ignore that),
> but what's the deal with VM_LOCKED?
> 
> Is the phrase "covert channel" going to come up somehow?

There's two (still hand wavy) conerns I see there.  First is the security
implication: timing writes to see cow and guess the shared data for
another apps VM_LOCKED region, second is just plain old complaints of
those rt latency sensitive apps that somehow have VM_LOCKED|VM_MERGE
and complain of COW fault time, probably just "don't do that".

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
