Date: Thu, 27 Jul 2006 08:33:01 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [patch 2/2] slab: always consider arch mandated alignment
In-Reply-To: <Pine.LNX.4.64.0607261239170.7520@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0607270823140.28805@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0607220748160.13737@schroedinger.engr.sgi.com>
 <20060723073500.GA10556@osiris.ibm.com> <Pine.LNX.4.64.0607230558560.15651@schroedinger.engr.sgi.com>
 <20060723162427.GA10553@osiris.ibm.com> <20060726085113.GD9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261303270.17613@sbz-30.cs.Helsinki.FI>
 <20060726101340.GE9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261325070.17986@sbz-30.cs.Helsinki.FI>
 <20060726105204.GF9592@osiris.boeblingen.de.ibm.com>
 <Pine.LNX.4.58.0607261411420.17986@sbz-30.cs.Helsinki.FI>
 <44C7AF31.9000507@colorfullife.com> <Pine.LNX.4.64.0607261118001.6608@schroedinger.engr.sgi.com>
 <44C7B842.5060606@colorfullife.com> <Pine.LNX.4.64.0607261153220.6896@schroedinger.engr.sgi.com>
 <44C7C261.6050602@colorfullife.com> <Pine.LNX.4.64.0607261229430.7132@schroedinger.engr.sgi.com>
 <44C7C46C.4090201@colorfullife.com> <Pine.LNX.4.64.0607261239170.7520@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jul 2006, Christoph Lameter wrote:
> We now want to say that SLAB_HWCACHE_ALIGN is only a suggestion to be 
> disposed of if debug is on whereas an explicitly specified alignment must be enforced?

Yes and that's what we have been saying all along. When you want 
performance, you use SLAB_HWCACHE_ALIGN and let the allocator do its job. 
I don't see much point from API point of view for the caller to explicitly 
ask for a given alignment and then in addition pass a 'yes I really meant' 
flag (SLAB_DEBUG_OVERRIDE).

So Christoph, unless you can point out a specific problem with my patch, 
I'll queue it up to Andrew. Thanks.

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
