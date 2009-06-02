Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 03CE26B0083
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:54:00 -0400 (EDT)
Date: Tue, 2 Jun 2009 10:06:00 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a
 file
In-Reply-To: <20090602071411.GE31556@wotan.suse.de>
Message-ID: <alpine.LFD.2.01.0906021005190.3351@localhost.localdomain>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-4-git-send-email-ebiederm@xmission.com> <20090602071411.GE31556@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>



On Tue, 2 Jun 2009, Nick Piggin wrote:
>
> Why is it called hotplug? Does it have anything to do with hardware?
> Because every concurrently changed software data structure in the
> kernel can be "hot"-modified, right?
> 
> Wouldn't file_revoke_lock be more appropriate?

I agree, "hotplug" just sounds crazy. It's "open" and "revoke", not 
"plug" and "unplug".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
