Subject: Re: VM problem with 2.4.8-ac9 (fwd)
References: <E15ZfK9-0002I3-00@the-village.bc.nu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 23 Aug 2001 00:19:58 -0600
In-Reply-To: <E15ZfK9-0002I3-00@the-village.bc.nu>
Message-ID: <m1zo8rl2lt.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> > Suspect code would be:
> > - tlb optimisations in recent -ac    (tasks dying with segfault)
> 
> Um the tlb optimisations go back to about 2.4.1-ac 8)
> 
> My guess would be the vm changes you and marcelo did

Can I ask which tlb optimisations these are.  I have a couple
of reports of dosemu killing the kernel on 2.4.7-ac6 and 2.4.8-ac7 and
similiar kernels, on machines with slow processors.  It has been
confirmed in dosemu without X and without any direct hardware
access. The kernel seems to oops in random interrupt handlers.  Just
off the cuff that feels like a lazy context switching bug.  As dosemu
plays with ldt's and lives in the vm86 syscall I can see it have
problems other code paths don't.

It is so weird I have been having a hard time believing the bug
reports.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
