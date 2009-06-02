Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D62D76B00CF
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:39:34 -0400 (EDT)
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
References: <m1oct739xu.fsf@fess.ebiederm.org>
	<1243893048-17031-4-git-send-email-ebiederm@xmission.com>
	<20090602071411.GE31556@wotan.suse.de>
	<alpine.LFD.2.01.0906021005190.3351@localhost.localdomain>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 02 Jun 2009 13:52:46 -0700
In-Reply-To: <alpine.LFD.2.01.0906021005190.3351@localhost.localdomain> (Linus Torvalds's message of "Tue\, 2 Jun 2009 10\:06\:00 -0700 \(PDT\)")
Message-ID: <m1y6sas6ht.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Tue, 2 Jun 2009, Nick Piggin wrote:
>>
>> Why is it called hotplug? Does it have anything to do with hardware?
>> Because every concurrently changed software data structure in the
>> kernel can be "hot"-modified, right?
>> 
>> Wouldn't file_revoke_lock be more appropriate?
>
> I agree, "hotplug" just sounds crazy. It's "open" and "revoke", not 
> "plug" and "unplug".

I guess this shows my bias in triggering this code path from pci
hotunplug.  Instead of with some system call.

I'm not married to the name.  I wanted file_lock but that is already
used, and I did call the method revoke.

The only place where hotplug gives a useful hint is that it makes it
clear we really are disconnecting the file descriptor from what lies
below it.  We can't do some weird thing like keep the underlying object.
Because the underlying object is gone.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
