Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E0EC8620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 05:10:14 -0500 (EST)
Message-ID: <4B31EC7C.7000302@gmail.com>
Date: Wed, 23 Dec 2009 11:10:04 +0100
From: Eric Dumazet <eric.dumazet@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
References: <4B30BDA8.1070904@linux.intel.com> <alpine.DEB.2.00.0912220945250.12048@router.home> <4B31BE44.1070308@linux.intel.com>
In-Reply-To: <4B31BE44.1070308@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Le 23/12/2009 07:52, Haicheng Li a ecrit :
> Christoph & Matt,
> 
> Thanks for the review. Node ids beyond nr_node_ids could be used in the
> case of
> memory hotadding.
> 
> Let me explain here:
> Firstly, original nr_node_ids = 1 + nid of highest POSSIBLE node.
> 
> Secondly, consider hotplug-adding the memories that are on a new_added
> node:
> 1. when acpi event is triggered:
> acpi_memory_device_add() -> acpi_memory_enable_device() -> add_memory()
> -> node_set_online()
> 
> The node_state[N_ONLINE] is updated with this new node added.
> And the id of this new node is beyond nr_node_ids.
> 

Then, this is a violation of the first statement :

nr_node_ids = 1 + nid of highest POSSIBLE node.

If your system allows hotplugging of new nodes, then POSSIBLE nodes should include them
at boot time.

Same thing for cpus and nr_cpus_ids. If a cpu is added, then its id MUST be < nr_cpus_ids

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
