Date: Mon, 04 Oct 2004 22:02:07 +0900 (JST)
Message-Id: <20041004.220207.10904358.taka@valinux.co.jp>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <1096836249.9667.100.camel@lade.trondhjem.org>
References: <1096831287.9667.61.camel@lade.trondhjem.org>
	<20041004.050320.78713249.taka@valinux.co.jp>
	<1096836249.9667.100.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trond.myklebust@fys.uio.no
Cc: marcelo.tosatti@cyclades.com, iwamoto@valinux.co.jp, haveblue@us.ibm.com, akpm@osdl.org, linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

Yes, I know what you're talking about.
The current kernel doesn't have any features about it.

So that I've been wondering if there might be any good solution
to help memory hot-removal. It would be nice if there were support
from filesystems and block devices.

> > However, while network is down network/cluster filesystems might not
> > release pages forever unlike in the case of block devices, which may
> > timeout or returns a error in case of failure.
> 
> Where is the difference? As far as the VM is concerned, it is a latency
> problem. The fact of whether or not it is a permanent hang, a hang with
> a long timeout, or just a slow device is irrelevant because the VM
> doesn't actually know about these devices.
> 
> > Each filesystem can control what the migration code does.
> > If it doesn't have anything to help memory migration, it's possible
> > to wait for the network coming up before starting memory migration,
> > or give up it if the network happen to be down. That's no problem.
> 
> Wrong. It *is* a problem: Filesystems aren't required to know anything
> about the particulars of the underlying block/network/... device timeout
> semantics either.
> 
> Think, for instance about EXT2. Where in the current code do you see
> that it is required to detect that it is running on top of something
> like the NBD device? Where does it figure out what the latencies of this
> device is?
> 
> AFAICS, most filesystems in linux/fs/* have no knowledge whatsoever
> about the underlying block/network/... devices and their timeout values.
> Basing your decision about whether or not you need to manage high
> latency situations just by inspecting the filesystem type is therefore
> not going to give very reliable results.

Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
