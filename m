Date: Tue, 9 Oct 2007 11:49:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave policy
In-Reply-To: <470B1C77.1080001@google.com>
Message-ID: <Pine.LNX.4.64.0710091148220.32730@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <20070830185122.22619.56636.sendpatchset@localhost>  <46E86148.9060400@google.com>
 <1189690357.5013.19.camel@localhost> <470B1C77.1080001@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 8 Oct 2007, Ethan Solomita wrote:

> 	Do we want do_get_mempolicy() to return a policy number with
> MPOL_CONTEXT set? That's what's happening with this patch, and I expect it'll
> confuse userland apps, e.g. numactl.

Do we have a consistent way to deal with MPOL_CONTEXT now? I thought this 
was just to test some ideas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
