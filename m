Date: Mon, 6 Oct 2008 15:26:51 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081006132651.GG3180@one.firstfloor.org>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <87abdintds.fsf@basil.nowhere.org> <20081006081717.GA20072@localhost.localdomain> <20081006084246.GC3180@one.firstfloor.org> <20081006091709.GB20852@localhost.localdomain> <20081006095628.GE3180@one.firstfloor.org> <20081006101221.GA21183@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081006101221.GA21183@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Linux interfaces are not supposed to be "interfaces for qemu" but generally
> > applicable interfaces.
> 
> I know. What about adding both personality() and flag for shmat()? I can
> prepare patch that implement flag for shmat().

It would be better to just fix all calls in qemu than
to add a new personality. There aren't that many anyways.

personality is really more a kludge for bug-to-bug compatibility
with old binaries (that is where the 3GB personality came from
to work around bugs in some old JVMs that could not deal with a full 4GB
address space), it shouldn't be really used for anything new. 

-Andi
-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
