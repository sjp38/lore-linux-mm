Date: Wed, 9 May 2007 18:44:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <b040c32a0705091826n5b7b3602laa3650fd4763e3@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705091843040.2781@schroedinger.engr.sgi.com>
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
 <20070509164859.15dd347b.pj@sgi.com>  <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
  <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
 <b040c32a0705091826n5b7b3602laa3650fd4763e3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Ken Chen wrote:

> On 5/9/07, Christoph Lameter <clameter@sgi.com> wrote:
> > > However, mbind shouldn't create discrepancy between what is allowed
> > > and what is promised, especially with MPOL_BIND policy.  Since a
> > > numa-aware app has already gone such a detail to request memory
> > > placement on a specific nodemask, they fully expect memory to be
> > > placed there for performance reason.  If kernel lies about it, we get
> > > very unpleasant performance issue.
> > 
> > How does the kernel lie? The memory is placed given the current cpuset and
> > memory policy restrictions.
> 
> sys_mbind lies.  A task in cpuset that has mems=0-7, it can do
> sys_mbind(MPOL_BIND, 0x100, ...) and such call will return success.

I thought we assume that people know what they are doing if they run such 
NUMA applications?

I do not think there is an easy way out given the current way of managing 
memory policies and allocation constraints.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
