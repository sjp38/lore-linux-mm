Date: Fri, 7 Mar 2008 14:44:28 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0803071443430.9202@sbz-30.cs.Helsinki.FI>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
 <Pine.LNX.4.64.0803061418430.15083@schroedinger.engr.sgi.com>
 <47D06F07.4070404@cs.helsinki.fi> <200803071320.58439.Jens.Osterkamp@gmx.de>
 <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Pekka J Enberg wrote:
> It might we worth it to look at other obviously wrong preempt_counts to 
> see if you can figure out a pattern of callers stomping on the memory.

And checking whether disabling debugging for the 'task_struct' cache makes 
the problem go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
