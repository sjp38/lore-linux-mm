Date: Tue, 22 Apr 2003 13:07:57 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <20030422165842.GG8931@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0304221303160.24424-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, William Lee Irwin III wrote:

> ISTR it being something on the order of running 32 instances of top(1),
> one per cpu, and then trying to fork().

oh, have you run any of the /proc fixes floating around? It still has some
pretty bad (quadratic) stuff left in, and done under tasklist_lock
read-help - if any write_lock_irq() of the tasklist lock hits this code
then you get an NMI assert. Please try either Manfred's or mine.

	Ingo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
