Date: Fri, 9 Nov 2007 13:50:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] x86_64: Configure stack size
In-Reply-To: <20071109134637.8d6fd2b3.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711091348170.17019@schroedinger.engr.sgi.com>
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com>
 <20071107191453.GC5080@shadowen.org> <200711080012.06752.ak@suse.de>
 <Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
 <20071109121332.7dd34777.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0711091242200.16284@schroedinger.engr.sgi.com>
 <20071109131057.a78c914b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0711091313040.16547@schroedinger.engr.sgi.com>
 <20071109134637.8d6fd2b3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ak@suse.de, apw@shadowen.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Andrew Morton wrote:

> Did you consider making the stack size a calculated-in-Kconfig-arithmetic
> thing rather than an offered-to-humans thing?  Derive it from CONFIG_NR_CPUS?

Estimating stack use based on NR_CPUS is a difficult thing. The estimates 
likely have to change as the use of the stack changes in the kernel. I'd 
rather have a constant there now. Maybe in the future we can come up with 
such a scheme.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
