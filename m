Date: Tue, 16 Jan 2007 12:51:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 8/8] Reduce inode memory usage for systems with a high
 MAX_NUMNODES
In-Reply-To: <6599ad830701161206w7dff0fa8y34f1e74f94ab9051@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701161249400.3074@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
  <20070116054825.15358.65020.sendpatchset@schroedinger.engr.sgi.com>
 <6599ad830701161152q75ff29cdo7306c9b8df5c351b@mail.gmail.com>
 <Pine.LNX.4.64.0701161152450.2780@schroedinger.engr.sgi.com>
 <6599ad830701161206w7dff0fa8y34f1e74f94ab9051@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2007, Paul Menage wrote:

> I was thinking runtime, unless MAX_NUMNODES is less than 64 in which
> case you can make the decision at compile time.
> 
> > 
> > If done at compile time then we will end up with a pointer to an unsigned
> > long for a system with <= 64 nodes. If we allocate the nodemask via
> > kmalloc then we will always end up with a mininum allocation size of 64
> > bytes.
> 
> Can't we get less overhead with a slab cache with appropriate-sized objects?

Ok but then we are going to have quite small objects. Plus we will have 
additional slab overhead per node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
