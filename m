Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l0GK71w4006273
	for <linux-mm@kvack.org>; Tue, 16 Jan 2007 12:07:01 -0800
Received: from ug-out-1314.google.com (ugfe2.prod.google.com [10.66.182.2])
	by zps36.corp.google.com with ESMTP id l0GK5A2B002120
	for <linux-mm@kvack.org>; Tue, 16 Jan 2007 12:06:52 -0800
Received: by ug-out-1314.google.com with SMTP id e2so1676731ugf
        for <linux-mm@kvack.org>; Tue, 16 Jan 2007 12:06:52 -0800 (PST)
Message-ID: <6599ad830701161206w7dff0fa8y34f1e74f94ab9051@mail.gmail.com>
Date: Tue, 16 Jan 2007 12:06:50 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC 8/8] Reduce inode memory usage for systems with a high MAX_NUMNODES
In-Reply-To: <Pine.LNX.4.64.0701161152450.2780@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116054825.15358.65020.sendpatchset@schroedinger.engr.sgi.com>
	 <6599ad830701161152q75ff29cdo7306c9b8df5c351b@mail.gmail.com>
	 <Pine.LNX.4.64.0701161152450.2780@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On 1/16/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Tue, 16 Jan 2007, Paul Menage wrote:
>
> > On 1/15/07, Christoph Lameter <clameter@sgi.com> wrote:
> > >
> > > This solution may be a bit hokey. I tried other approaches but this
> > > one seemed to be the simplest with the least complications. Maybe someone
> > > else can come up with a better solution?
> >
> > How about a 64-bit field in struct inode that's used as a bitmask if
> > there are no more than 64 nodes, and a pointer to a bitmask if there
> > are more than 64 nodes. The filesystems wouldn't need to be involved
> > then, as the bitmap allocation could be done in the generic code.
>
> How would we decide if there are more than 64 nodes? Runtime or compile
> time?

I was thinking runtime, unless MAX_NUMNODES is less than 64 in which
case you can make the decision at compile time.

>
> If done at compile time then we will end up with a pointer to an unsigned
> long for a system with <= 64 nodes. If we allocate the nodemask via
> kmalloc then we will always end up with a mininum allocation size of 64
> bytes.

Can't we get less overhead with a slab cache with appropriate-sized objects?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
