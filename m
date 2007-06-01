Date: Fri, 1 Jun 2007 11:43:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180718106.5278.28.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>  <200705312243.20242.ak@suse.de>
 <20070601093803.GE10459@minantech.com>  <200706011221.33062.ak@suse.de>
 <1180718106.5278.28.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Lee Schermerhorn wrote:

> Like Gleb, I find the different behaviors for different memory regions
> to be unnatural.  Not because of the fraction of applications or
> deployments that might use them, but because [speaking for customers] I
> expect and want to be able to control placement of any object mapped
> into an application's address space, subject to permissions and
> privileges.

Same here and I wish we had a clean memory region based implementation.
But that is just what your patches do *not* provide. Instead they are file 
based. They should be memory region based.

Would you please come up with such a solution?

> Then why does Christoph keep insisting that "page cache pages" must
> always follow task policy, when shmem, tmpfs and anonymous pages don't
> have to?

No I just said that the page cache handling is consistently following task 
policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
