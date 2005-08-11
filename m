From: David Howells <dhowells@redhat.com>
In-Reply-To: <200508110812.59986.phillips@arcor.de> 
References: <200508110812.59986.phillips@arcor.de>  <42F57FCA.9040805@yahoo.com.au> <200508090724.30962.phillips@arcor.de> <20050808145430.15394c3c.akpm@osdl.org> 
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS 
Date: Thu, 11 Aug 2005 10:26:30 +0100
Message-ID: <26569.1123752390@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:

> 
> This filesystem-specific flag needs to be prevented from escaping into other
> subsystems that might interact, such as VM.  The current usage is mainly
> for directories, except for Reiser4, which uses it for journalling
> ..
> +	SetPageMiscFS(page);

Can you please retain the *PageFsMisc names I've been using in my stuff?

In my opinion putting the "Fs" bit first gives a clearer indication that this
is a bit exclusively for the use of filesystems in general.

> +#define PG_fs_misc		 8	/* don't let me spread */

Should perhaps be:

  +#define PG_fs_misc		 8	/* for internal filesystem use only */

> and NFS, which presses it into service in a network cache coherency role.

The patches to make the AFS filesystem use it were removed, pending a release
of updated filesystem caching patches.

The NFS filesystem patches that use it haven't yet found there way into
Andrew's tree, but are also being held pending FS-Cache being updated.

If you wish, I will send the FS-Cache patch, the AFS patch and the NFS patch
to Andrew so that you can see. CacheFS needs more work, however, before that
can be re-released.

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
