Date: Wed, 23 Feb 2005 08:06:56 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: mapping user data in kernel
In-Reply-To: <22326A72AE6CF647B89C8371452F6BFA7E7D90@frex02.fr.nds.com>
Message-ID: <Pine.LNX.4.58.0502230756380.14346@server.graphe.net>
References: <22326A72AE6CF647B89C8371452F6BFA7E7D90@frex02.fr.nds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Hermann, Guy" <GHermann@nds.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Feb 2005, Hermann, Guy wrote:

> The general idea consists in a user process that gives data from its userspace to the kernel.
> And the kernel makes them available to other user processes.

There is already a shared memory implementation in Linux that allows the
sharing of data between processes.

See shm_open

> 1st question:
> Is such a treament (mapping in the kernel a page belonging to a user process that is not the
> current one) relevant ? (can we use pgd_offset for a task->mm that does not belong to the current
> process?)

Yes, the kernel is able to map the same page into the address spaces of
multiple processes. And no, the page tables are separate thus you
wont be able to use addresses of page tables pages from one process for
the next.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
