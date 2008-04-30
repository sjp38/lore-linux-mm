Date: Wed, 30 Apr 2008 22:45:09 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080430204509.GJ20451@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430193416.GE8597@us.ibm.com> <20080430195237.GE20451@one.firstfloor.org> <20080430200249.GA6903@us.ibm.com> <20080430201932.GH20451@one.firstfloor.org> <20080430202303.GB6903@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430202303.GB6903@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> If so, I'll hold off
> on any further review.

That's not what I asked for.  Some of your comments were very useful
by pointing to real bugs and other problems, just some others were not. Please 
continue reviewing, just make sure that all the comments are focused on 
improving that particular code in the concrete current application.

For example the bulk of the changes needed for PPC I expect will just be an 
additional add on patchkit.

> > The hugetlbfs code actually doesn't claim that.
> 
> The hugetlb.c code is architecture independent and roughly generic (it
> doesn't know a whole lot about the underlying architecture itself).
> hstates are defined and used in this independent code -- hence my
> perspective that we want to make sure it is flexible enough to handle
> other architectures than x86_64, or at least easily extensible to them.

It is extensible to them, but with some further changes (that is what the 
patchkit claimed)

For power I think it would be best if you just started on the incremental
patches needed (in fact there were already such an addon, perhaps that
can be just improved)

> Well, Nick was talking about adding the powerpc bits to his stack when
> he submited for -mm, so these discussions should be happening now,
> AFAICT.

The whole thing is work in progress and will undoubtedly change more
before it is really used.  Nothing is put in stone yet.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
