Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 85C166B0055
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:03:50 -0400 (EDT)
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2EDA25> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 3 Jun 2009 11:03:32 -0400
Date: Wed, 3 Jun 2009 07:57:40 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
In-Reply-To: <m13aaintb1.fsf@fess.ebiederm.org>
Message-ID: <alpine.DEB.1.10.0906030754550.17143@makko.or.mcafeemobile.com>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-18-git-send-email-ebiederm@xmission.com> <alpine.DEB.1.10.0906020944540.12866@makko.or.mcafeemobile.com> <m1eiu2qqho.fsf@fess.ebiederm.org> <alpine.DEB.1.10.0906021429570.12866@makko.or.mcafeemobile.com>
 <m13aaintb1.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Jun 2009, Eric W. Biederman wrote:

> I am not clear what problem you have.
> 
> Is it the sprinkling the code that takes and removes the lock?  Just
> the VFS needs to be involved with that.  It is a slightly larger
> surface area than doing the work inside the file operations as we
> sometimes call the same method from 3-4 different places but it is
> definitely a bounded problem.
> 
> Is it putting in the handful lines per subsystem to actually use this
> functionality?  At that level something generic that is maintained
> outside of the subsystem is better than the mess we have with 4-5
> different implementations in the subsystems that need it, each having
> a different assortment of bugs.

Come on, only in the open fast path, there are at least two spin 
lock/unlock and two atomic ops. Without even starting to count all the 
extra branches and software added.
Is this stuff *really* needed, or we can faitly happily live w/out?


- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
