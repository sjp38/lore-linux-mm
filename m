From: Paul Mackerras <paulus@samba.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15497.61055.615126.619184@argo.ozlabs.ibm.com>
Date: Sat, 9 Mar 2002 22:14:07 +1100 (EST)
Subject: Re: [bkpatch] do_mmap cleanup
In-Reply-To: <m2y9h2mqph.fsf@trasno.mitica>
References: <20020308185350.E12425@redhat.com>
	<m2y9h2mqph.fsf@trasno.mitica>
Reply-To: paulus@samba.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Juan Quintela <quintela@mandrakesoft.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Juan Quintela writes:

> Please, don't do that, export another function that does exactly that.
> sys_munmap is declared as asmlinkage, and some architectures (at
> least ppc used to have) need especial code to be able to call
> asmlinkage functions from inside the kernel.

Huh?  asmlinkage doesn't do anything on PPC, and never has.  It only
makes any difference on i386 and ia64 - see include/linux/linkage.h.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
