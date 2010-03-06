Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B80296B0047
	for <linux-mm@kvack.org>; Sat,  6 Mar 2010 04:24:34 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19346.8003.99263.626961@pilspetsen.it.uu.se>
Date: Sat, 6 Mar 2010 10:24:19 +0100
From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH] rmap: Fix Bugzilla Bug #5493
In-Reply-To: <20100305093834.GG17078@lisa.in-ulm.de>
References: <20100305093834.GG17078@lisa.in-ulm.de>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <lk@c--e.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christian Ehrhardt writes:
 > 
 > Hi,
 > 
 > this patch fixes bugzilla Bug
 > 
 >         http://bugzilla.kernel.org/show_bug.cgi?id=5493
 > 
 > This bug describes a search complexity failure in rmap if a single
 > anon_vma has a huge number of vmas associated with it.
 > 
 > The patch makes the vma prio tree code somewhat more reusable and then uses
 > that to replace the linked list of vmas in an anon_vma with a prio_tree.
 > 
 > Timings for the test program in the original kernel code and
 > responsiveness of the system during the test improve dramatically.
 > 
 > NOTE: This needs an Ack from someone who can compile on arm and parisc.

Compile and boot-tested on an ARM ixp4xx machine.

Tested-by: Mikael Pettersson <mikpe@it.uu.se> (ARM bits only)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
