Date: Tue, 29 Apr 2003 09:57:29 +0200
From: Jan Hudec <bulb@ucw.cz>
Subject: Re: questions on swapping
Message-ID: <20030429075729.GA668@vagabond>
References: <OF48B89A80.1B070B4E-ON65256D16.002A0894@celetron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF48B89A80.1B070B4E-ON65256D16.002A0894@celetron.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heerappa Hunje <hunjeh@celetron.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 28, 2003 at 01:24:17PM +0530, Heerappa Hunje wrote:
> 
> Dear William,
> 
> Thanks for the reply and information, well i wanted to know  that how can i
> see the source code of linux when iam working on linux being in the root,
> what pathname name should i type to get to the source code file of linux.

It depends on where you have placed it! If you have installed kernel
from distribution binary package, you have to download it first. If you
have downloaded a source package, query your package manager program. If
you compiled yourself, you should already know.

> 2. if i have the device driver module's source code written for perticular
> device than  where should i store it, so that it will support to my device
> whenever any user seeks it.

If you have it in a form of patch, you apply it using
  patch -p1 <the-patch-file
command in the top-level directory of kernel sources (unless the driver
states otherwise)

If you have sources that already have makefile to compile off-tree, you
can place it anywhere. You just need to tell it where kernel headers
reside (you may or may not need the whole tree - depends on the
particular driver).

If you have just a source without makefile, you may either place them in
kernel (besides other drivers of the same type), modify the Makefiles
and config and compile in kernel tree, or you can write makefile to make
it compile separately.

> 3. During installation of linux, what if i assign the swapping space4 times
> of my present memory size OR less than the present memory size. I mean will
> it have any problems in system performance in both the cases.

Too much swap can not hurt except by wasting your precious disk space.
Linux does not rely on swap space being present at all, so too little
swap won't principialy hurt either. It's just your applications may not
have enough space.

In linux, each page is either in swap or in memory, so you have size of
ram + swap available as virtual memory (part of that is used by kernel
itself)

> 4. what command should i type to know the version of my present OS.

uname -r

-------------------------------------------------------------------------------
						 Jan 'Bulb' Hudec <bulb@ucw.cz>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
