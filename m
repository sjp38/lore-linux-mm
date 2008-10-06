Date: Mon, 6 Oct 2008 11:56:28 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081006095628.GE3180@one.firstfloor.org>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <87abdintds.fsf@basil.nowhere.org> <20081006081717.GA20072@localhost.localdomain> <20081006084246.GC3180@one.firstfloor.org> <20081006091709.GB20852@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081006091709.GB20852@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > And personality() is not thread local/safe, so it's not a particularly
> > good interface to use later.
> 
> qemu can call personality() before any threads will be created.

It still makes it unsuitable for a lot of other applications.
e.g. a JVM using 32bit pointers couldn't use it because it would
affect native C threads running in the same process.

> 
> > Per system call switches are preferable
> > and more flexible.
> 
> Per syscall switches are cool, but I don't see any advantage from it for 
> qemu.

Linux interfaces are not supposed to be "interfaces for qemu" but generally
applicable interfaces.

-Andi
-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
