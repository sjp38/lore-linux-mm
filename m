Date: Wed, 19 Oct 2005 08:31:43 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Allow outside read access to a tasks memory policy
In-Reply-To: <200510191534.29538.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0510190831000.12887@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0510181126280.8305@schroedinger.engr.sgi.com>
 <200510191534.29538.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, 19 Oct 2005, Andi Kleen wrote:

> On Tuesday 18 October 2005 20:30, Christoph Lameter wrote:
> > Currently access to the memory policy of a task from outside of a task is
> > not possible since there are no locking conventions. A task must always be
> > able to access its memory policy without the necessity to take a lock in
> > order to allow alloc_pages to operate efficiently.
> 
> While you could probably make it work for vma policy, it's impossible or hard 
> to do the same thing for process policy, which is strictly thread local.

The proposal here deals with making is possible to allow read access to 
the process policy. It already works fine for the vma policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
