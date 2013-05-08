Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 91DDF6B005A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 15:39:16 -0400 (EDT)
Date: Wed, 8 May 2013 12:39:07 -0700
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [REGRESSION] SLAB allocator (on Zynq)
Message-ID: <20130508193906.GC32546@atomide.com>
References: <9d9b2266-e09e-4366-80ef-3df5db775f25@TX2EHSMHS033.ehs.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9d9b2266-e09e-4366-80ef-3df5db775f25@TX2EHSMHS033.ehs.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Cc: Michal Simek <michal.simek@xilinx.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Hi,

* SA?ren Brinkmann <soren.brinkmann@xilinx.com> [130508 12:26]:
> Hi,
> 
> I compiled the latest kernel for Zynq and ran into issues when the SLAB
> allocator is selected. Booting crashes early with a NULL pointer
> dereference (boot log attached).
> Switching to the SLUB allocator resolves the issue (boot log attached).

There's a fix for this now in lkml thread
"[GIT PULL] SLAB changes for v3.10":

http://lkml.org/lkml/2013/5/8/374#

Regards,

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
