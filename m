Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1EMNWua388776
	for <linux-mm@kvack.org>; Mon, 14 Feb 2005 17:23:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1EMNViW322776
	for <linux-mm@kvack.org>; Mon, 14 Feb 2005 15:23:31 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1EMNVwl030167
	for <linux-mm@kvack.org>; Mon, 14 Feb 2005 15:23:31 -0700
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
	sys_page_migrate
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050214220148.GA11832@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	 <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
	 <1108242262.6154.39.camel@localhost>
	 <20050214135221.GA20511@lnx-holt.americas.sgi.com>
	 <1108407043.6154.49.camel@localhost>
	 <20050214220148.GA11832@lnx-holt.americas.sgi.com>
Content-Type: text/plain
Date: Mon, 14 Feb 2005 14:22:54 -0800
Message-Id: <1108419774.6154.58.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-02-14 at 16:01 -0600, Robin Holt wrote:
> On Mon, Feb 14, 2005 at 10:50:42AM -0800, Dave Hansen wrote:
> > On Mon, 2005-02-14 at 07:52 -0600, Robin Holt wrote:
> > > The node mask is a list of allowed.  This is intended to be as near
> > > to a one-to-one migration path as possible.
> > 
> > If that's the case, it would make the kernel internals a bit simpler to
> > only take a "from" and "to" node, instead of those maps.  You'll end up
> > making multiple syscalls, but that shouldn't be a problem.  
> 
> Then how do you handle overlapping nodes.  If I am doing a 5->4, 4->3,
> 3->2, 2->1 shift in the memory placement and had only a from and to node,
> I would end up calling multiple times.  This would end up in memory shifting
> from 5->4 on the first, 4->3 on the second, ... with the end result of
> all memory shifting to a single node.

Can you give an example of when you'd actually want to do this?

> On a seperate topic, I would guess the syscall time is trivial compared
> to the time to walk the page tables.

I'd certainly agree.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
