Date: Tue, 21 Feb 2006 11:19:58 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] 0/4 Migration Cache Overview
In-Reply-To: <1140547791.5207.21.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0602211117570.20413@schroedinger.engr.sgi.com>
References: <1140190593.5219.22.camel@localhost.localdomain>
 <Pine.LNX.4.64.0602170816530.30999@schroedinger.engr.sgi.com>
 <1140195598.5219.77.camel@localhost.localdomain>
 <Pine.LNX.4.64.0602170906030.31408@schroedinger.engr.sgi.com>
 <43FA8690.3070608@yahoo.com.au> <20060221184016.GA19696@dmt.cnet>
 <Pine.LNX.4.64.0602211001110.19955@schroedinger.engr.sgi.com>
 <1140547791.5207.21.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Feb 2006, Lee Schermerhorn wrote:

> Are the swap ptes used for migrating pages still reserving swap space on
> real swap devices?  I thought this was what the migration cache was
> trying to avoid.  Now each running instance of direct migration limits
> itself to MIGRATE_CHUNK_SIZE [currently] 256 pages, so if the system has
> much swap space at all, this shouldn't place too much of a load on swap
> space.  But, it does require that one have SOME swap space to migrate,
> right?

Right. If the kernel configured to not include swap functionality then the 
kernel will not include page migration capabilities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
