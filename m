From: David Howells <dhowells@redhat.com>
In-Reply-To: <200508110823.53593.phillips@arcor.de> 
References: <200508110823.53593.phillips@arcor.de>  <42F57FCA.9040805@yahoo.com.au> <20050808145430.15394c3c.akpm@osdl.org> <200508110812.59986.phillips@arcor.de> 
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS 
Date: Thu, 11 Aug 2005 10:31:12 +0100
Message-ID: <26681.1123752672@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:

> Note: I have not fully audited the NFS-related colliding use of page flags
> bit 8,

Nor will you be able to until the NFS caching patches are released.

> to verify that it really does not escape into VFS or MM from NFS, in fact I
> have misgivings about end_page_fs_misc which uses this flag

end_page_fs_misc() simply makes use of the same waitqueues as other page
flags. This is surely preferable to instituting a whole new table of
waitqueues just for this flag.

> but has no in-tree users to show how it is used

It did have one: fs/afs/. But the patch has been temporarily removed. Look
back into, say, 2.6.13-rc2-mm1.

> and, hmm, isn't even _GPL.  What is up?

EXPORT_SYMBOL_GPL() is a bad idea. It should die as it gives the wrong
impression.

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
