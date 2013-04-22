Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id AADC16B0034
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 16:44:17 -0400 (EDT)
Date: Mon, 22 Apr 2013 13:44:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
Message-Id: <20130422134415.32c7f2cac07c924bff3017a4@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>
References: <1366225776.8817.28.camel@pippen.local.home>
	<alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>

On Wed, 17 Apr 2013 17:03:21 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Wed, 17 Apr 2013, Steven Rostedt wrote:
> 
> > The slab.c code has a size check macro that checks the size of the
> > following structs:
> > 
> > struct arraycache_init
> > struct kmem_list3
> > 
> > The index_of() function that takes the sizeof() of the above two structs
> > and does an unnecessary __builtin_constant_p() on that. As sizeof() will
> > always end up being a constant making this always be true. The code is
> > not incorrect, but it just adds added complexity, and confuses users and
> > wastes the time of reviewers of the code, who spends time trying to
> > figure out why the builtin_constant_p() was used.
> > 
> > This patch is just a clean up that makes the index_of() code a little
> > bit less complex.
> > 
> > Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Adding Pekka to the cc.

I ducked this patch because it seemed rather pointless - but a little
birdie told me that there is a secret motivation which seems pretty
reasonable to me.  So I shall await chirp-the-second, which hopefully
will have a fuller and franker changelog ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
