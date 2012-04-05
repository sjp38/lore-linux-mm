Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 61E506B007E
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 17:37:03 -0400 (EDT)
Received: by iajr24 with SMTP id r24so3148623iaj.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 14:37:01 -0700 (PDT)
Date: Thu, 5 Apr 2012 14:37:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] Documentation: mm: Add compact_node on
 Documentation/sysctl/vm.txt
In-Reply-To: <1333644489-31466-1-git-send-email-standby24x7@gmail.com>
Message-ID: <alpine.DEB.2.00.1204051434491.17852@chino.kir.corp.google.com>
References: <1333644489-31466-1-git-send-email-standby24x7@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Apr 2012, Masanari Iida wrote:

> The Documentation/sysctl/vm.txt does include "compact_memory",
> but it doesn't include "compact_node".
> 

That's because /proc/sys/vm/compact_node doesn't exist.

The per-node compaction trigger is at 
/sys/device/system/node/nodeX/compact which is appropriately documented in 
Documentation/ABI/testing/sysfs-devices-node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
