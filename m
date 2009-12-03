Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CB892600762
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 17:00:47 -0500 (EST)
Date: Thu, 03 Dec 2009 14:00:45 -0800 (PST)
Message-Id: <20091203.140045.67902314.davem@davemloft.net>
Subject: Re: [RFC PATCH 4/6] networking: rework socket to fd mapping using
 alloc-file
From: David Miller <davem@davemloft.net>
In-Reply-To: <20091203195917.8925.84203.stgit@paris.rdu.redhat.com>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
	<20091203195917.8925.84203.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: eparis@redhat.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

From: Eric Paris <eparis@redhat.com>
Date: Thu, 03 Dec 2009 14:59:17 -0500

> Currently the networking code does interesting things allocating its struct
> file and file descriptors.  This patch attempts to unify all of that and
> simplify the error paths.  It is also a part of my patch series trying to get
> rid of init-file and get-empty_filp and friends.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

I'm fine with this:

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
