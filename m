From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003131746.JAA90301@google.engr.sgi.com>
Subject: Re: [PATCH] mincore for i386, against 2.3.51
Date: Mon, 13 Mar 2000 09:46:36 -0800 (PST)
In-Reply-To: <Pine.BSO.4.10.10003121941460.5358-100000@funky.monkey.org> from "Chuck Lever" at Mar 12, 2000 07:45:53 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Couple of things:

#1
>  static struct vm_operations_struct shm_vm_ops = {
>  	open:	shm_open,	/* callback for a new vm-area open */
>  	close:	shm_close,	/* callback for when the vm-area is released */
> +	incore:	shm_incore,
>  	nopage:	shm_nopage,
>  	swapout:shm_swapout,
>  };

shmzero_vm_ops should also probably have a incore function. /dev/zero is
quite similar to shm, except the locking protocol is a little different
(look at shmzero_nopage and shm_nopage), you should be able to seperate
out the shm incore() function into a basic routine/#define that both shm
and /dev/zero can use. Let me know if you need help with this.

#2. It wasn't very clear to me how MAP_ANON pages are being handled. Maybe
I did not read the patch closely enough.

#3. If you have the time, it might make sense to pump out the #pages via
/proc/pid/maps too (although I don't know whether that will break some
apps that already know the output format).

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
