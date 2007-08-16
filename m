Date: Thu, 16 Aug 2007 11:34:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Use MPOL_PREFERRED for system default policy
In-Reply-To: <1187274221.5900.27.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708161133250.16816@schroedinger.engr.sgi.com>
References: <1187120671.6281.67.camel@localhost>
 <Pine.LNX.4.64.0708141250200.30703@schroedinger.engr.sgi.com>
 <1187122156.6281.77.camel@localhost>  <1187122945.6281.92.camel@localhost>
 <1187274221.5900.27.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2007, Lee Schermerhorn wrote:

> Given that the mem policy does the right thing with this patch, can we
> merge it?  I think it cleans up the mem policy concepts to have
> MPOL_DEFAULT mean "use default policy for this context/scope" rather
> than have an additional allocation behavior of its own.

I still have not gotten my head around this one. Lets wait awhile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
