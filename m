Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 10E3B6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:21:08 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id oB8LI9ZB018448
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 13:18:09 -0800
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by hpaq3.eem.corp.google.com with ESMTP id oB8LHUA0020916
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 13:18:07 -0800
Received: by pxi4 with SMTP id 4so616596pxi.30
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 13:18:07 -0800 (PST)
Date: Wed, 8 Dec 2010 13:18:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
In-Reply-To: <20101207232000.GA5353@shaohui>
Message-ID: <alpine.DEB.2.00.1012081316530.15658@chino.kir.corp.google.com>
References: <20101207010033.280301752@intel.com> <20101207010139.681125359@intel.com> <20101207182420.GA2038@mgebm.net> <20101207232000.GA5353@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Cc: Eric B Munson <emunson@mgebm.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010, Shaohui Zheng wrote:

> Eric,
> 	the major change on the patchset is on the interface, for the v8 emulator,
> we accept David's per-node debugfs add_memory interface, we already included
> in the documentation patch. the change is very small, so it is not obvious.
> 

It's still stale as Eric mentioned: for instance, the reference to 
/sys/kernel/debug/node/add_node which is now under mem_hotplug.  There may 
be other examples as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
