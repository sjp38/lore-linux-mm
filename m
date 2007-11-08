Date: Wed, 7 Nov 2007 16:42:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] x86_64: Configure stack size
In-Reply-To: <200711080012.06752.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
References: <20071107004357.233417373@sgi.com> <20071107004710.862876902@sgi.com>
 <20071107191453.GC5080@shadowen.org> <200711080012.06752.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007, Andi Kleen wrote:

> 
> > We seem to be growing two different mechanisms here for 32bit and 64bit.
> > This does seem a better option than that in 32bit CONFIG_4KSTACKS etc.
> > IMO when these two merge we should consolidate on this version.
> 
> Best would be to not change it at all for 64bit for now.
> 
> We can worry about the 16k CPU systems when they appear, but shorter term
> it would just lead to other crappy kernel code relying on large stacks when
> it shouldn't.

Well we cannot really test these systems without these patches and when 
they become officially available then its too late for merging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
