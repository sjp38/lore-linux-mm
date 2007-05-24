Date: Wed, 23 May 2007 20:55:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524033925.GD14349@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de>
 <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
 <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com>
 <20070524033925.GD14349@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Nick Piggin wrote:

> > Hummm... We have not tested with my patch yet. May save another 200k.
> 
> Saved 12K. Shuld it have been more? I only applied the last patch you
> sent (plus the initial SLUB_DEBUG fix).

Yeah. The code size should have shrunk significantly. It seems that the 
inlining instead of saving memory as on x86_64 wasted memory and ate up 
the winnings through the shrink. Could you try the patch before to see how 
much actually is saved by shrinking?

> Admittedly, I am not involved with any such tiny Linux projects, however
> why should half of memory be available to userspace? What about a router
> or firewall that basically does all work in kernel?

It would also work fine with SLUB? Its about 12k code + data on 
x86_64. I doubt that this would be too much of an issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
