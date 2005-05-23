Date: Mon, 23 May 2005 22:20:46 +0900 (JST)
Message-Id: <20050523.222046.113099660.taka@valinux.co.jp>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050521001118.GB30327@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
	<20050520.182624.67793132.taka@valinux.co.jp>
	<20050521001118.GB30327@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chandra,

> > I think it's very heavy to move all pages, which are mapped to removing
> > regions, to new classes every time. It always happens when doing exec()
> > or exit(), while munmap and closing file don't.
> > Pages associating with libc.so or text of shells might move around
> > the all classes.
> > 
> > IMHO, it would be enough to just leave them as they are.
> > These pages would be released a little later if no class touch them,
> > or they might be accessed from another class to migrate another
> > class, or they might reused in the same class.
> 
> No, it will be incorrect, as the class that is using the page doesn't need
> these pages anymore, we should not be charging them for those pages.
> 
> May be we should do something light while keeping the accounting proper.
> Any ideas ?

I understand your intention. But I don't think it's always proper.
It wouldn't be bad idea to leave pages for perl scripts launched
by Apache, as they may be reused soon.
Each class may tend to re-execute the same programs.

OTOH, pages as a cache of closed file may not be reused by the same
class again, though they're counted as valid pages for the class.

I guess both of them are in gray area.

> > I feel it's not needed to move these pages in hurry.
> > I prefer the implementation light.
> > What do you think?
> > 
> > 
> > BTW, the memory controller would be a good new to video streaming
> > guys, I guess.


Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
