Message-ID: <3A70747F.2010305@valinux.com>
Date: Thu, 25 Jan 2001 11:46:23 -0700
From: Jeff Hartmann <jhartmann@valinux.com>
MIME-Version: 1.0
Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
		<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
		<20010125165001Z132264-460+11@vger.kernel.org> <E14LpvQ-0008Pw-00@mail.valinux.com>
		<20010125175308Z130507-460+45@vger.kernel.org> <E14Lqyt-0003z6-00@mail.valinux.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:

> ** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Thu, 25 Jan
> 2001 11:13:35 -0700
> 
> 
> 
>> You need to have your driver in the early bootup process then.  When 
>> memory is being detected (but before the free lists are created.), you 
>> can set your page as being reserved. 
> 
> 
> But doesn't this mean that my driver has to be built as part of the kernel?
> The end-user won't have the source code, so he won't be able to compile it, only
> link it.  As it stands now, our driver is a binary that can be shipped
> separately.

Sorry, this is the only way to do it properly.  Binary kernel drivers 
are intensely evil. ;)  Open the driver and you have no problems.  You 
also do know that binary kernel drivers mean you'll be chasing every 
kernel release, having to provide several different flavors of your 
binary depending on the users kernel configuration.  It also means that 
when kernel interfaces change, people won't be nice and change your code 
over to the new interfaces for you.  For instance if a function 
depreciates, your code might be automatically moved to use the 
replacement function if your in the standard kernel.  If your a binary 
module, you have to do all that maintaining yourself.

(There are several other reasons to have open kernel modules.  I won't 
go into the entire argument, since that could take all day.)

You might be able to get away with making detection of this page open, 
and keep the rest of the driver closed.  However that is something for 
Linus to decided, not I.  I believe he doesn't like putting in hooks in 
the kernel for binary modules.  Since all you really want to do is 
reserve the page during early bootup, perhaps he might let you get away 
with it.  Not my call though.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
