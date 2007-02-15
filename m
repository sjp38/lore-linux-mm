Date: Wed, 14 Feb 2007 16:13:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] mm: NUMA replicated pagecache
In-Reply-To: <20070215001053.GB29797@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0702141611300.4902@schroedinger.engr.sgi.com>
References: <20070213060924.GB20644@wotan.suse.de>
 <Pine.LNX.4.64.0702141057060.975@schroedinger.engr.sgi.com>
 <20070215001053.GB29797@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Nick Piggin wrote:

> But no arguments, this doesn't aim to do replication of the same virtual
> address. If you did come up with such a scheme, however, you would still
> need a replicated pagecache for it as well.

Well there is always the manual road. Trigger something that scans over 
the address space and replicates pages that are not local. And yes we 
would still need your replication infrastructure. I would definitely like 
such a feature in the kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
