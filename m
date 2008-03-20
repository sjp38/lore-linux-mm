Date: Wed, 19 Mar 2008 17:03:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [2/2] vmallocinfo: Add caller information
In-Reply-To: <20080319214227.GA4454@elte.hu>
Message-ID: <Pine.LNX.4.64.0803191659410.4645@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com>
 <20080319214227.GA4454@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008, Ingo Molnar wrote:

> 
> * Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Add caller information so that /proc/vmallocinfo shows where the 
> > allocation request for a slice of vmalloc memory originated.
> 
> please use one simple save_stack_trace() instead of polluting a dozen 
> architectures with:

save_stack_trace() depends on CONFIG_STACKTRACE which is only available 
when debugging is compiled it. I was more thinking about this as a 
generally available feature.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
