Date: Fri, 26 May 2000 22:41:13 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526224113.A22069@pcep-jamie.cern.ch>
References: <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com> <20000526190208.A21856@pcep-jamie.cern.ch> <20000526181509.R10082@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000526181509.R10082@redhat.com>; from sct@redhat.com on Fri, May 26, 2000 at 06:15:09PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > The stacked private address_spaces I described don't have to be shared
> > between address_spaces in a single mm.  You can have one per vma --
> > that's simple but maybe wasteful.
> 
> That's basically exactly what davem's stuff did.

Ok, I shall look more carefully at davem's code.
Is this the most recent one?:

> Date:   Wed, 17 May 2000 11:00:34 +0100
> Subject: [davem@redhat.com: my paging work]
> From:   "Stephen C. Tweedie" <sct@redhat.com>
> 
> Hi,
> 
> Here's davem's page-based swapout snapshot.  It's UNFINISHED + DANGEROUS
> WILL_EAT_YOUR_DISK (his words!), but somebody may want to archive this
> and pick up on the work in 2.5.
> 
> --Stephen
> 
> ----- Forwarded message from "David S. Miller" <davem@redhat.com> -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
