From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Thu, 31 May 2007 12:43:19 +0200
References: <1180467234.5067.52.camel@localhost> <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com> <20070531064753.GA31143@minantech.com>
In-Reply-To: <20070531064753.GA31143@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705311243.20119.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > The faulted page will use the memory policy of the task that faulted it 
> > in. If that process has numa_set_localalloc() set then the page will be 
> > located as closely as possible to the allocating thread.
> 
> Thanks. But I have to say this feels very unnatural.

What do you think is unnatural exactly? First one wins seems like a quite 
natural policy to me.

> So to have 
> desirable effect I have to create shared memory with shmget?

shmget behaves the same.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
