Date: Thu, 22 Dec 2005 14:55:03 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch] mm: Patch to convert global dirty_exceeded flag to per-node node_dirty_exceeded
Message-ID: <20051222225503.GA6416@localhost.localdomain>
References: <20051222223139.GC3704@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051222223139.GC3704@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 22, 2005 at 02:31:39PM -0800, Ravikiran G Thirumalai wrote:
> Patch to convert global dirty_exceeded flag to per-node
> node_dirty_exceeded.

This depends on the compile fix for node_to_fist_cpu I posted before 
if this code has to run on x86_64/ia64

http://marc.theaimsgroup.com/?l=linux-kernel&m=113529019215045&w=2

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
