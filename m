Date: Wed, 31 Oct 2007 14:34:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] hotplug memory remove - walk_memory_resource for ppc64
Message-Id: <20071031143423.586498c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071031142846.aef9c545.kamezawa.hiroyu@jp.fujitsu.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	<18178.52359.953289.638736@cargo.ozlabs.ibm.com>
	<1193771951.8904.22.camel@dyn9047017100.beaverton.ibm.com>
	<20071031142846.aef9c545.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 31 Oct 2007 14:28:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> ioresource was good structure for remembering "which memory is conventional
> memory" and i386/x86_64/ia64 registered conventional memory as "System RAM",
> when I posted patch. (just say "System Ram" is not for memory hotplug.)
> 
If I remember correctly, System RAM is for kdump (to know which memory should
be dumped.) Then, memory-hotadd/remove has to modify it anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
