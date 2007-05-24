Date: Thu, 24 May 2007 14:17:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <1180040744.5327.110.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Lee Schermerhorn wrote:

> Same use cases for using mbind() at all.  I want to specify the
> placement of memory backing any of my address space.  A shared mapping
> of a regular file is, IMO, morally equivalent to a shared memory region,
> with the added semantic that is it automatically initialized from the
> file contents, and any changes persist after the file is closed.  [One
> related semantic that Linux is missing is to initialize the shared
> mapping from the file, but not writeback any changes--e.g.,
> MAP_NOWRITEBACK.  Some "enterprise unix" support this, presumably at
> ISV/customer request.]

I think Andi was looking for an actual problem that is solved by this 
patchset. Any user feedback that triggered this solution?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
