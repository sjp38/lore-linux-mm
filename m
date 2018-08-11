Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3063F6B0003
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 04:08:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id o4-v6so9005260wrn.19
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 01:08:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s10-v6sor4532943wru.89.2018.08.11.01.08.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 Aug 2018 01:08:47 -0700 (PDT)
Date: Sat, 11 Aug 2018 10:08:46 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 3/3] mm/memory_hotplug: Cleanup
 unregister_mem_sect_under_nodes
Message-ID: <20180811080846.GA24835@techadventures.net>
References: <20180810152931.23004-1-osalvador@techadventures.net>
 <20180810152931.23004-4-osalvador@techadventures.net>
 <20180810153727.c9ae4aab518f1b84e04c999a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180810153727.c9ae4aab518f1b84e04c999a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri, Aug 10, 2018 at 03:37:27PM -0700, Andrew Morton wrote:
> I guess so.  But the node_online() check was silently removed?

A node can only get offline if all the memory and CPUs associated
with it are removed.

This is being checked in remove_memory()->try_offline_node().
There we check whether the node has still valid sections or not,
and if there are still CPUs associated to it.

In the case that either we still have valid sections or that we have
CPUs linked to this node, we do not offline it.

So we cannot really be removing a memory from a node that is offline,
that is why it is safe to drop the check.

It was my mistake not to explain that properly in the changelog though.
I will send a V2 fixing up all you pointed out and explaining
why it is safe to drop the check.

Thanks
-- 
Oscar Salvador
SUSE L3
