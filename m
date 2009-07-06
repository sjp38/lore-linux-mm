Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 249AB6B005D
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:27:05 -0400 (EDT)
In-reply-to: <20090706165522.GR2714@wotan.suse.de> (message from Nick Piggin
	on Mon, 6 Jul 2009 18:55:22 +0200)
Subject: Re: [rfc][patch 2/3] fs: make use of new helper functions
References: <20090706165438.GQ2714@wotan.suse.de> <20090706165522.GR2714@wotan.suse.de>
Message-Id: <E1MNsYt-0002N5-KE@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 06 Jul 2009 20:05:07 +0200
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Jul 2009, Nick Piggin wrote:
> Update some fs code to make use of new helper functions introduced
> in the previous patch. Should be no significant change in behaviour
> (except CIFS now calls send_sig under i_lock, via inode_truncate_ok).

ACK for the fuse parts.

I think even the "if (newsize < oldsize)" conditionals could be
removed before calling truncate_pagecache() as that check is performed
inside truncate_pagecache().

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
