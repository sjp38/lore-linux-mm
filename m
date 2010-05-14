Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36F686B0208
	for <linux-mm@kvack.org>; Fri, 14 May 2010 04:04:14 -0400 (EDT)
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation
 APIs
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTinLT5g5SKjqmQlS2kxvvMq1gsi1jPDgOKTnrT-q@mail.gmail.com>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	 <1273756816.5605.3547.camel@twins>
	 <AANLkTinLT5g5SKjqmQlS2kxvvMq1gsi1jPDgOKTnrT-q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 14 May 2010 10:03:34 +0200
Message-ID: <1273824214.5605.3625.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Changli Gao <xiaosuo@gmail.com>
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, Roland Dreier <rolandd@cisco.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Divy Le Ray <divy@chelsio.com>, "James E.J. Bottomley" <James.Bottomley@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, Eric Dumazet <eric.dumazet@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 22:08 +0800, Changli Gao wrote:
> > NAK, I really utterly dislike that inatomic argument. The alloc side
> > doesn't function in atomic context either. Please keep the thing
> > symmetric in that regards.
> >
>=20
> There are some users, who release memory in atomic context. for
> example: fs/file.c: fdmem.=20

urgh, but yeah, aside from not using vmalloc to allocate fd tables one
needs to deal with this.

But if that is the only one, I'd let them do the workqueue thing that's
already there. If there really are more people wanting to do this, then
maybe add: kvfree_atomic().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
