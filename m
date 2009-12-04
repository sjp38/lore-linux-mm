Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBEEE60021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:12:15 -0500 (EST)
In-reply-to: <20091203195933.8925.8783.stgit@paris.rdu.redhat.com> (message
	from Eric Paris on Thu, 03 Dec 2009 14:59:33 -0500)
Subject: Re: [RFC PATCH 6/6] fs: move get_empty_filp() deffinition to internal.h
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com> <20091203195933.8925.8783.stgit@paris.rdu.redhat.com>
Message-Id: <E1NGSKh-0004ov-4y@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 04 Dec 2009 08:12:03 +0100
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 03 Dec 2009, Eric Paris wrote:
> All users outside of fs/ of get_empty_filp() have been removed.  This patch
> moves the definition from the include/ directory to internal.h so no new
> users crop up and removes the EXPORT_SYMBOL.  I'd love to see open intents
> stop using it too, but that's a problem for another day and a smarter
> developer!

ACK for 5/6 and 6/6.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
