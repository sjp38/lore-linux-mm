In-reply-to: <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Mon, 13 Oct 2008 16:49:19 +0200)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu>
Message-Id: <E1KpPFv-0003ol-NV@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 13 Oct 2008 17:22:47 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

And BTW the whole thing seems to be broken WRT umount.  Getting a
reference to a dentry or an inode without also getting reference to a
vfsmount is going to result in "VFS: Busy inodes after unmount of
%s. Self-destruct in 5 seconds.  Have a nice day...\n".  And getting a
reference to the vfsmount will result in EBUSY when trying to umount,
which is also not what we want.

So it seemst that this two pass method will not work with dentries or
inodes at all :(

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
