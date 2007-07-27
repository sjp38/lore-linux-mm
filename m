Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge
	plans for 2.6.23]
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <20070727014749.85370e77.akpm@linux-foundation.org>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de>
	 <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu>
	 <20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	 <20070726094024.GA15583@elte.hu>
	 <20070726030902.02f5eab0.akpm@linux-foundation.org>
	 <1185454019.6449.12.camel@Homer.simpson.net>
	 <20070726110549.da3a7a0d.akpm@linux-foundation.org>
	 <1185513177.6295.21.camel@Homer.simpson.net>
	 <1185521021.6295.50.camel@Homer.simpson.net>
	 <20070727014749.85370e77.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 11:40:44 +0200
Message-Id: <1185529244.7851.51.camel@Homer.simpson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 01:47 -0700, Andrew Morton wrote:

> Anyway, blockdev pagecache is a problem, I expect.  It's worth playing with
> that patch.

(may tinker a bit, but i'm way rusty.  ain't had the urge to mutilate
anything down there in quite a while... works just fine for me these
days)

> Another problem is atime updates.  You really do want to mount noatime. 
> Because with atimes enabled, each touch of a file will touch its inode and
> will keep its backing blockdev pagecache page in core.

Yeah, I mount noatime,nodiratime,data=writeback.  ext3's journal with my
crusty old disk/fs is painful as heck.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
