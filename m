Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD6460079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 17:45:38 -0500 (EST)
Date: Wed, 9 Dec 2009 22:44:38 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: VFS and IMA API patch series please pull
Message-ID: <20091209224438.GS14381@ZenIV.linux.org.uk>
References: <1260393952.3344.18.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1260393952.3344.18.camel@localhost>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-cachefs@redhat.com, ecryptfs-devel@lists.launchpad.net, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-security-module@vger.kernel.org, rdunlap@xenotime.net, zohar@linux.vnet.ibm.com, jmorris@namei.org, serue@us.ibm.com, dhowells@redhat.com, steved@redhat.com, tiwai@suse.de, tyhicks@linux.vnet.ibm.com, kirkland@canonical.com, akpm@linux-foundation.org, npiggin@suse.de, wli@holomorphy.com, mel@csn.ul.ie, shuber2@gmail.com, dsmith@redhat.com, jack@suse.cz, jmalicki@metacarta.com, hch@lst.de, bfields@fieldses.org, neilb@suse.de, agruen@suse.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, miklos@szeredi.hu, jens.axboe@oracle.com, arnd@arndb.de, drepper@redhat.com, a.p.zijlstra@chello.nl, Trond.Myklebust@netapp.com, matthew@wil.cx, hooanon05@yahoo.co.jp, mingo@elte.hu, rusty@rustcorp.com.au, penberg@cs.helsinki.fi, clg@fr.ibm.com, hugh.dickins@tiscali.co.uk, vapier@gentoo.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, eric.dumazet@gmail.com, sgrubb@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, Dec 09, 2009 at 04:25:52PM -0500, Eric Paris wrote:

> I'm not sure who the best person to pull this would be.  VFS maintainer?
> Al?  Should I just send straight to Linus?  I'm not sure what the best
> path is.  All of the individual fs changes have been acked by their
> respective maintainers and the IMA work has been acked by the IMA
> maintainer.  The only patches without CLEAR acks and review are the two
> which remove the get_empty_filp() and init_file() calls.

Sigh...  I'll merge it with my queue and push to Linus along with the
rest.  It conflicts with some of the pending stuff, but seeing that I
hadn't yelled in time, it's my PITA to deal with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
