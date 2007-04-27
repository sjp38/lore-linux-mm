Date: Fri, 27 Apr 2007 00:10:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/10] SLUB: Fix sysfs directory handling
Message-Id: <20070427001031.a6402f4b.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704270001230.5388@schroedinger.engr.sgi.com>
References: <20070427042655.019305162@sgi.com>
	<20070427042907.759384015@sgi.com>
	<20070426233138.5c6707b7.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704270001230.5388@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Apr 2007 00:02:36 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 26 Apr 2007, Andrew Morton wrote:
> 
> > > + * :[flags-]size:[memory address of kmemcache]
> > > + */
> > 
> > Exposing kernel addresses to unprivileged userspace is considered poor
> > form.
> 
> Hmmmm... We could drop the address if I can make sure that all the other
> unifying bits are in the string.

Tejun today sent out a patch "[PATCH 3/4] ida: implement idr based id
allocator" which could be used here to give each slab a unique
integer identifier.

It might be a bit overkillish.  I suspect slab_number++ would suffice. 
Make it u64 if we're really paranoid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
