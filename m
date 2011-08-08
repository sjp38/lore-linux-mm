Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D13796B016A
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 11:05:25 -0400 (EDT)
Received: by fxg9 with SMTP id 9so5479045fxg.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 08:05:23 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 1/2] fuse: delete dead .write_begin and .write_end aops
References: <1311626135-14279-1-git-send-email-jweiner@redhat.com>
	<20110725204942.GA12183@infradead.org>
Date: Mon, 08 Aug 2011 17:05:20 +0200
In-Reply-To: <20110725204942.GA12183@infradead.org> (Christoph Hellwig's
	message of "Mon, 25 Jul 2011 16:49:42 -0400")
Message-ID: <87aabkeyfj.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Johannes Weiner <jweiner@redhat.com>, fuse-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Christoph Hellwig <hch@infradead.org> writes:

> On Mon, Jul 25, 2011 at 10:35:34PM +0200, Johannes Weiner wrote:
>> Ever since 'ea9b990 fuse: implement perform_write', the .write_begin
>> and .write_end aops have been dead code.
>> 
>> Their task - acquiring a page from the page cache, sending out a write
>> request and releasing the page again - is now done batch-wise to
>> maximize the number of pages send per userspace request.
>
> The loop code still calls them uncondtionally.  This actually is a big
> as write_begin and write_end require filesystems specific locking,
> and might require code in the filesystem to e.g. update the ctime
> properly.  I'll let Miklos chime in if leaving them in was intentional,
> and if it was a comment is probably justified.

Loop checks for ->write_begin() and falls back to ->write if the former
isn't defined.

So I think the patch is fine.  I tested loop over fuse, and it still
works after the patch.

Added to for-next.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
