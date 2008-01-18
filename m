Date: Fri, 18 Jan 2008 12:10:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
In-Reply-To: <200801182104.22486.ioe-lkml@rameria.de>
Message-ID: <Pine.LNX.4.64.0801181208520.31319@schroedinger.engr.sgi.com>
References: <20080118183011.354965000@sgi.com> <20080118183011.917801000@sgi.com>
 <200801182104.22486.ioe-lkml@rameria.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008, Ingo Oeser wrote:

> Hi Mike,
> 
> On Friday 18 January 2008, travis@sgi.com wrote:
> > +config THREAD_ORDER
> > +	int "Kernel stack size (in page order)"
> > +	range 1 3

THREAD_ORDER can also be used to consolidate the stack size with the 
choices available for i386. In that cases the choices are 0 and 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
