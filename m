Date: Fri, 9 Nov 2007 12:45:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] x86_64: Configure stack size
In-Reply-To: <20071109121332.7dd34777.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711091242200.16284@schroedinger.engr.sgi.com>
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com>
 <20071107191453.GC5080@shadowen.org> <200711080012.06752.ak@suse.de>
 <Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
 <20071109121332.7dd34777.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ak@suse.de, apw@shadowen.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Andrew Morton wrote:

> otoh, I doubt if anyone will actually ship an NR_CPUS=16384 kernel, so it
> isn't terribly pointful.

Our competition (Cray) just announced a product featuring up to 21k 
cpus although that is a cluster. We are definitely getting there...

> So I'm wobbly.  Could we please examine the alternatives before proceeding?

This works fine with a 32k stack on IA64 with 4k processors. So I tend to 
think of this as a solution that is already working on another platform. 
An 8k stack is also going to be tough with 4k processors on x86_64 which 
we will have soon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
