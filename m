Date: Fri, 1 Jun 2007 13:59:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
In-Reply-To: <46606C71.9010008@goop.org>
Message-ID: <Pine.LNX.4.64.0706011357290.4664@schroedinger.engr.sgi.com>
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org>
 <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>
 <46606C71.9010008@goop.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Jeremy Fitzhardinge wrote:

> > An allocation of zero bytes usually indicates that the code is not dealing 
> > with a special case. Later code may operate on the allocated object. I 
> > think its clearer and cleaner if code would deal with that special case 
> > explicitly. We have seen a series of code pieces that do uncomfortably 
> > looking operations on structures with no objects.
> >   
> 
> I disagree.  There are plenty of boundary conditions where 0 is not
> really a special case, and making it a special case just complicates
> things.  I think at least some of the patches posted to silence this
> warning have been generally negative for code quality.  If we were
> seeing lots of zero-sized allocations then that might indicate something
> is amiss, but it seems to me that there's just a scattered handful.
> 
> I agree that it's always a useful debugging aid to make sure that
> allocated regions are not over-run, but 0-sized allocations are not
> special in this regard.

Still insisting on it even after the discovery of the cpuset kmalloc(0) issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
