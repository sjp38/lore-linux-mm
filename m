Message-Id: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:39 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/15] per device dirty throttling -v6
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

The latest version of the per device dirty throttling patches.

I put in quite a few comments, and added an patch to do per task dirty
throttling as well, for RFCs sake :-)

I haven't yet come around to do anything but integrety testing on this code
base, ie. it built a kernel. I hope to do more tests shorty if time permits...

Perhaps the people on bugzilla.kernel.org #7372 might be willing to help out
there.

Oh, patches are against 2.6.21-mm2

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
