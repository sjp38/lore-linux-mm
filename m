Date: Mon, 04 Oct 2004 05:03:20 +0900 (JST)
Message-Id: <20041004.050320.78713249.taka@valinux.co.jp>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <1096831287.9667.61.camel@lade.trondhjem.org>
References: <20041003140723.GD4635@logos.cnet>
	<20041004.033559.71092746.taka@valinux.co.jp>
	<1096831287.9667.61.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trond.myklebust@fys.uio.no
Cc: marcelo.tosatti@cyclades.com, iwamoto@valinux.co.jp, haveblue@us.ibm.com, akpm@osdl.org, linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

> > Pages for NFS also might be pinned with network problems.
> > One of the ideas is to restrict NFS to allocate pages from
> > specific memory region, sot that all memory except the region
> > can be hot-removed. And it's possible to implementing whole
> > migrate_page method, which may handled stuck pages.
> 
> Why do you want to special-case this?
>
> The above is a generic condition: any filesystem can suffer from the
> equivalent problem of a failure or slow response in the underlying
> device. Making an NFS-specific hack is just counter-productive to
> solving the generic problem.

However, while network is down network/cluster filesystems might not
release pages forever unlike in the case of block devices, which may
timeout or returns a error in case of failure.

Each filesystem can control what the migration code does.
If it doesn't have anything to help memory migration, it's possible
to wait for the network coming up before starting memory migration,
or give up it if the network happen to be down. That's no problem.

Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
