Date: Mon, 5 May 2008 15:32:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
In-Reply-To: <20080505152451.6dceec74.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.10.0805051530590.15653@chino.kir.corp.google.com>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213814.3140.66080.sendpatchset@localhost.localdomain> <20080505152451.6dceec74.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 May 2008, Andrew Morton wrote:

> IOW, have we chosen the best, most maintainable representation for these
> things?
> 

There was discussion early on in the development of the memory controller 
that bytes were going to be used as the base unit for accounting.  I had 
disagreed in favor of kB since page sizes are always in these increments 
and historically the kernel has exported statistics this way via 
/proc/meminfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
