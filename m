Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 611FE6B005A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:44:33 -0400 (EDT)
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2ED5AD> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Tue, 2 Jun 2009 12:57:46 -0400
Date: Tue, 2 Jun 2009 09:51:42 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
In-Reply-To: <1243893048-17031-18-git-send-email-ebiederm@xmission.com>
Message-ID: <alpine.DEB.1.10.0906020944540.12866@makko.or.mcafeemobile.com>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-18-git-send-email-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jun 2009, Eric W. Biederman wrote:

> From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
>  fs/eventpoll.c |   39 ++++++++++++++++++++++++++++++++-------
>  1 files changed, 32 insertions(+), 7 deletions(-)

This patchset gives me the willies for the amount of changes and possible 
impact on many subsystems.
Without having looked at the details, are you aware that epoll does not 
act like poll/select, and fds are not automatically removed (as in, 
dequeued from the poll wait queue) in any foreseeable amount of time after 
a POLLERR is received?
As far as the usespace API goes, they have the right to remain there.



- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
