Subject: Re: [bkpatch] do_mmap cleanup
References: <20020308185350.E12425@redhat.com>
From: Juan Quintela <quintela@mandrakesoft.com>
In-Reply-To: <20020308185350.E12425@redhat.com>
Date: 09 Mar 2002 03:15:38 +0100
Message-ID: <m2y9h2mqph.fsf@trasno.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "benjamin" == Benjamin LaHaise <bcrl@redhat.com> writes:

benjamin> diff -Nru a/include/linux/mm.h b/include/linux/mm.h
benjamin> --- a/include/linux/mm.h	Fri Mar  8 18:46:34 2002
benjamin> +++ b/include/linux/mm.h	Fri Mar  8 18:46:34 2002
benjamin> @@ -492,20 +492,11 @@
benjamin> extern int do_munmap(struct mm_struct *, unsigned long, size_t);
benjamin> +extern long sys_munmap(unsigned long, size_t);

Please, don't do that, export another function that does exactly that.
sys_munmap is declared as asmlinkage, and some architectures (at
least ppc used to have) need especial code to be able to call
asmlinkage functions from inside the kernel.

Declaring a __sys_munmap() that does the work and is exported and then
sys_munmap to be only the syscall entry is better.

asmlinkage long sys_munmap(unsigned long addr, size_t len)


 
Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
