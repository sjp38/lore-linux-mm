Date: 14 Feb 2005 20:18:40 +0100
Date: Mon, 14 Feb 2005 20:18:40 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
Message-ID: <20050214191840.GA57423@muc.de>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com> <m1vf8yf2nu.fsf@muc.de> <20050212121228.GA15340@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050212121228.GA15340@lnx-holt.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> For our use, the batch scheduler will give an intermediary program a
> list of processes and a series of from-to node pairs.  That process would
> then ensure all the processes are stopped, scan their VMAs to determine
> what regions are mapped by more than one process, which are mapped
> by additional processes not in the job, and make this system call for
> each of the unique ranges in the job to migrate their pages from one
> node to the next.  I believe Ray is working on a library and a standalone
> program to do this from a command line.

Sounds quite ugly. 

Do you have evidence that this is a common use case? (jobs having stuff
mapped from programs not in the job). If not I think it's better
to go with a simple interface, not one that is unusable without
a complex user space library.

If you mean glibc etc. only then the best solution for that would be probably
to use the (currently unmerged) arbitary file mempolicy code for this and set
 a suitable attribute that prevents moving.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
