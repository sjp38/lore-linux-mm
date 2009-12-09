Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 29B3F60079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 17:39:40 -0500 (EST)
Date: Thu, 10 Dec 2009 09:38:03 +1100 (EST)
From: James Morris <jmorris@namei.org>
Subject: Re: VFS and IMA API patch series please pull
In-Reply-To: <1260393952.3344.18.camel@localhost>
Message-ID: <alpine.LRH.2.00.0912100937110.18606@tundra.namei.org>
References: <1260393952.3344.18.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-cachefs@redhat.com, ecryptfs-devel@lists.launchpad.net, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-security-module@vger.kernel.org, rdunlap@xenotime.net, Mimi Zohar <zohar@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, David Howells <dhowells@redhat.com>, steved@redhat.com, tiwai@suse.de, viro@zeniv.linux.org.uk, tyhicks@linux.vnet.ibm.com, kirkland@canonical.com, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, wli@holomorphy.com, mel@csn.ul.ie, shuber2@gmail.com, dsmith@redhat.com, jack@suse.cz, jmalicki@metacarta.com, hch@lst.de, "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de, agruen@suse.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, miklos@szeredi.hu, Jens Axboe <jens.axboe@oracle.com>, arnd@arndb.de, drepper@redhat.com, a.p.zijlstra@chello.nl, Trond.Myklebust@netapp.com, matthew@wil.cx, hooanon05@yahoo.co.jp, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, penberg@cs.helsinki.fi, clg@fr.ibm.com, hugh.dickins@tiscali.co.uk, vapier@gentoo.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, "David S. Miller" <davem@davemloft.net>, eric.dumazet@gmail.com, sgrubb@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009, Eric Paris wrote:

> I'm not sure who the best person to pull this would be.  VFS maintainer?
> Al?  Should I just send straight to Linus?  I'm not sure what the best
> path is.  All of the individual fs changes have been acked by their
> respective maintainers and the IMA work has been acked by the IMA
> maintainer.  The only patches without CLEAR acks and review are the two
> which remove the get_empty_filp() and init_file() calls.

It should probably go via Al, due to all the VFS core changes, but I can 
take it in my tree if needed.

-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
