Date: Sat, 09 Oct 2004 01:52:39 +0900 (JST)
Message-Id: <20041009.015239.74741436.taka@valinux.co.jp>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041008124149.GI16028@logos.cnet>
References: <20041008100010.GB16028@logos.cnet>
	<20041008.212319.19886370.taka@valinux.co.jp>
	<20041008124149.GI16028@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Marcelo.

> > > > > That is, if we can't migrate the page, try to write it out?
> > > 
> > > I just didnt understand the logic very well, maybe I should just 
> > > go reread the code.
> > > 
> > > Thanks!
> 
> I'm thinking about how to implement a nonblocking version of generic_migrate_page().
> 
> For this purpose its really bad to allocate swap space to anonymous pages, well
> need to figure out someother way of blocking the users via pagetablefault.
> 
> Like a "virtual" swap space but without allocating swap map space. 

I've also ever thought to implement such a device.
It would be nice if you can design it simple.

Mr.Iwamoto thought otherwise and posted another opinion on the lhms
list, though. I felt it also has a point.

iwamoto> I don't think requiring swap is a big deal.  If you don't have a
iwamoto> dedicated swap device, which case I think unusual, you can swapon a
iwamoto> regular file.

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
