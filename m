Subject: Re: VM problem with 2.4.8-ac9 (fwd)
Date: Thu, 23 Aug 2001 13:53:22 +0100 (BST)
In-Reply-To: <m1zo8rl2lt.fsf@frodo.biederman.org> from "Eric W. Biederman" at Aug 23, 2001 12:19:58 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15Ztz8-0003mC-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Can I ask which tlb optimisations these are.  I have a couple
> of reports of dosemu killing the kernel on 2.4.7-ac6 and 2.4.8-ac7 and
> similiar kernels, on machines with slow processors.  It has been

Unrelated. The tlb shootdown fix is ages old and fixes a real bug in Linus
tree.

There are interactions between the segment reload patch and vm86() operation
where segmnet registers happen to be left holding CS/DS values that make
the kernel think its optimising a kernel->kernel transition when its seeing
old vm86 mode selectors

Andi Kleen is working on that one
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
