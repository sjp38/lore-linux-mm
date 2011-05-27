Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 640536B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 19:27:40 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p4RNRcmi018581
	for <linux-mm@kvack.org>; Fri, 27 May 2011 16:27:38 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz17.hot.corp.google.com with ESMTP id p4RNRaeK000327
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 16:27:37 -0700
Received: by pvc21 with SMTP id 21so1447682pvc.39
        for <linux-mm@kvack.org>; Fri, 27 May 2011 16:27:36 -0700 (PDT)
Date: Fri, 27 May 2011 16:27:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
In-Reply-To: <20110527231708.GB3214@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1105271623410.9445@chino.kir.corp.google.com>
References: <20110414065146.GA19685@tiehlicka.suse.cz> <20110414160145.0830.A69D9226@jp.fujitsu.com> <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz> <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
 <20110527124705.GB4067@tiehlicka.suse.cz> <alpine.DEB.2.00.1105271157350.2533@chino.kir.corp.google.com> <20110527231708.GB3214@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Sat, 28 May 2011, Michal Hocko wrote:

> > CONFIG_NODES_SHIFT is used for UMA machines that are using DISCONTIGMEM 
> > usually because they have very large holes; such machines don't need 
> > things like mempolicies but do need the data structures that abstract 
> > ranges of memory in the physical address space.  This build breakage 
> > probably isn't restricted to only alpha, you could probably see it with at 
> > least ia64 and mips as well.
> 
> Hmmm. I just find strange that some UMA arch uses functions like
> {first,next}_online_node.
> 

They shouldn't, but they do use NUMA data structures like pg_data_t for 
DISCONTIGMEM.  The MAX_NUMNODES > 1 optimization in nodemask.h is to 
prevent doing things like node_weight() on a nodemask when we know that 
only one bit will ever be set, otherwise we could make it conditional on 
CONFIG_NEED_MULTIPLE_NODES.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
