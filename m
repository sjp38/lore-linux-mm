Date: Thu, 25 Jan 2001 12:18:43 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3A706CCF.8010400@valinux.com>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
	<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
	<20010125165001Z132264-460+11@vger.kernel.org> <E14LpvQ-0008Pw-00@mail.valinux.com>
	<20010125175308Z130507-460+45@vger.kernel.org>
Subject: Re: ioremap_nocache problem?
Message-Id: <20010125181559Z131219-224+42@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Hartmann <jhartmann@valinux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Thu, 25 Jan
2001 11:13:35 -0700


> You need to have your driver in the early bootup process then.  When 
> memory is being detected (but before the free lists are created.), you 
> can set your page as being reserved. 

But doesn't this mean that my driver has to be built as part of the kernel?
The end-user won't have the source code, so he won't be able to compile it, only
link it.  As it stands now, our driver is a binary that can be shipped
separately.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
