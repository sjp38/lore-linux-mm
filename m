Subject: Re: [bkpatch] do_mmap cleanup
References: <20020308185350.E12425@redhat.com> <m2y9h2mqph.fsf@trasno.mitica>
	<15497.61055.615126.619184@argo.ozlabs.ibm.com>
From: Juan Quintela <quintela@mandrakesoft.com>
In-Reply-To: <15497.61055.615126.619184@argo.ozlabs.ibm.com>
Date: 09 Mar 2002 22:17:22 +0100
Message-ID: <m27kolmof1.fsf@trasno.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulus@samba.org
Cc: Benjamin LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "paul" == Paul Mackerras <paulus@samba.org> writes:

paul> Juan Quintela writes:
>> Please, don't do that, export another function that does exactly that.
>> sys_munmap is declared as asmlinkage, and some architectures (at
>> least ppc used to have) need especial code to be able to call
>> asmlinkage functions from inside the kernel.

paul> Huh?  asmlinkage doesn't do anything on PPC, and never has.  It only
paul> makes any difference on i386 and ia64 - see include/linux/linkage.h.

Humm, having to relook at the question.  When I begin to work in
supermount, there was a need for a patch (trampoline.S), that I don't
need anymore after I remove one asmlinkage from the exported
functions.  But if you told that it is not needed, you are the ppc
maintainer, can be that any side effect made that code not to be
needed anymore.

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
