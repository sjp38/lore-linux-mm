Message-Id: <200508042258.j74Mwsg18638@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Getting rid of SHMMAX/SHMALL ?
Date: Thu, 4 Aug 2005 15:58:52 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20050804225413.GH8266@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andi Kleen' <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote on Thursday, August 04, 2005 3:54 PM
> > This might be too low on large system.  We usually stress shm pretty hard
> > for db application and usually use more than 87% of total memory in just
> > one shm segment.  So I prefer either no limit or a tunable.
> 
> With large system you mean >32GB right?

Yes, between 32 GB - 128 GB.  On larger numa box in the 256 GB and upward,
we have to break shm segment into one per-numa-node and then the limit
should be OK.  I was concerned with SMP box with large memory.

> I think on a large systems some tuning is reasonable because they likely
> have trained admins. I'm more worried on reasonable defaults for the
> class of systems with 0-4GB

Sounds reasonable to me.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
