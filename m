Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E56A6B00AE
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:37:25 -0400 (EDT)
Date: Wed, 3 Jun 2009 08:37:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
Message-ID: <20090603063721.GD27563@wotan.suse.de>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-4-git-send-email-ebiederm@xmission.com> <20090602071411.GE31556@wotan.suse.de> <alpine.LFD.2.01.0906021005190.3351@localhost.localdomain> <m1y6sas6ht.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1y6sas6ht.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 01:52:46PM -0700, Eric W. Biederman wrote:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
> 
> > On Tue, 2 Jun 2009, Nick Piggin wrote:
> >>
> >> Why is it called hotplug? Does it have anything to do with hardware?
> >> Because every concurrently changed software data structure in the
> >> kernel can be "hot"-modified, right?
> >> 
> >> Wouldn't file_revoke_lock be more appropriate?
> >
> > I agree, "hotplug" just sounds crazy. It's "open" and "revoke", not 
> > "plug" and "unplug".
> 
> I guess this shows my bias in triggering this code path from pci
> hotunplug.  Instead of with some system call.
> 
> I'm not married to the name.  I wanted file_lock but that is already
> used, and I did call the method revoke.

Definitely it is not going to be called hotplug in the generic
vfs layer :)

 
> The only place where hotplug gives a useful hint is that it makes it
> clear we really are disconnecting the file descriptor from what lies
> below it.

Isn't that hotUNplug?

But anyway hot plug/unplug is a purely hardware concept. Revoke
for "unplug", please, including naming of patches, changelogs,
and locks etc.


>  We can't do some weird thing like keep the underlying object.
> Because the underlying object is gone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
