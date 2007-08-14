Date: Tue, 14 Aug 2007 12:51:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Use MPOL_PREFERRED for system default policy
In-Reply-To: <1187120671.6281.67.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708141250200.30703@schroedinger.engr.sgi.com>
References: <1187120671.6281.67.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Lee Schermerhorn wrote:

> Now, system default policy, except during boot, is "local 
> allocation".  By using the MPOL_PREFERRED mode with a negative
> value of preferred node for system default policy, MPOL_DEFAULT
> will never occur in the 'policy' member of a struct mempolicy.
> Thus, we can remove all checks for MPOL_DEFAULT when converting
> policy to a node id/zonelist in the allocation paths.

Isnt it possible to set a task policy or VMA policy to MPOL_DEFAULT 
through the API? For the VMA policy this would mean fall back to task 
policy. Is that still possible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
