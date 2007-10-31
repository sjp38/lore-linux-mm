Subject: Re: Interesting Bug in page migration via mbind()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710311406570.22599@schroedinger.engr.sgi.com>
References: <1193863506.5299.139.camel@localhost>
	 <Pine.LNX.4.64.0710311406570.22599@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 17:16:13 -0400
Message-Id: <1193865374.5299.148.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 14:07 -0700, Christoph Lameter wrote:
> On Wed, 31 Oct 2007, Lee Schermerhorn wrote:
> 
> > How to address?
> 
> Looks like we are not updating the vma information correctly when 
> splitting vmas?

Possibly that or the prio_tree contents or lookup are not quite right.
This is all common code--not mempolicy/migration specific--so you'd
think it would be pretty solid by now.  I'm still looking with some
instrumentation--peeling back the onion...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
