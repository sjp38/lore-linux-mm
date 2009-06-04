Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CF46E6B0055
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 20:56:10 -0400 (EDT)
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2EDD1C> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 3 Jun 2009 20:55:48 -0400
Date: Wed, 3 Jun 2009 17:50:01 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
In-Reply-To: <m1tz2xox7n.fsf@fess.ebiederm.org>
Message-ID: <alpine.DEB.1.10.0906031708480.18001@makko.or.mcafeemobile.com>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-18-git-send-email-ebiederm@xmission.com> <alpine.DEB.1.10.0906020944540.12866@makko.or.mcafeemobile.com> <m1eiu2qqho.fsf@fess.ebiederm.org> <alpine.DEB.1.10.0906021429570.12866@makko.or.mcafeemobile.com>
 <m13aaintb1.fsf@fess.ebiederm.org> <alpine.DEB.1.10.0906030754550.17143@makko.or.mcafeemobile.com> <m1tz2xox7n.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Eric W. Biederman wrote:

> What code are you talking about?
> 
> To the open path a few memory writes and a smp_wmb.  No atomics and no
> spin lock/unlocks.
> 
> Are you complaining because I retain the file_list?

Sorry, did I overlook the patch? Weren't a couple of atomic ops and a spin 
lock/unlock couple present in __dentry_open() (same sort of the release 
path)?
And that's only like 5% of the code touched by the new special handling of 
the file operations structure (basically, every f_op access ends up being 
wrapped by two atomic ops and other extra code).
The question, that I'd like to reiterate is, is this stuff really needed?
Anyway, my complaint ends here and I'll let others evaluate if merging 
this patchset is worth the cost.


- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
