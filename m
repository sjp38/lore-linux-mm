Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7629E600727
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:23:13 -0500 (EST)
Date: Fri, 4 Dec 2009 15:22:50 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [RFC PATCH 2/6] pipes: use alloc-file instead of duplicating
	code
Message-ID: <20091204142250.GF8742@kernel.dk>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com> <20091203195902.8925.2985.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091203195902.8925.2985.stgit@paris.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Dec 03 2009, Eric Paris wrote:
> The pipe code duplicates the functionality of alloc-file and init-file.  Use
> the generic vfs functions instead of duplicating code.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: Jens Axboe <jens.axboe@oracle.com>

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
