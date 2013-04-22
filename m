Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0A7B06B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 18:35:43 -0400 (EDT)
Date: Mon, 22 Apr 2013 15:35:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug fix PATCH v2] numa, cpu hotplug: Change links of CPU and
 node when changing node number by onlining CPU
Message-Id: <20130422153541.04ba682f13910cfede0d2ff7@linux-foundation.org>
In-Reply-To: <5170D4CB.20900@jp.fujitsu.com>
References: <5170D4CB.20900@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: kosaki.motohiro@gmail.com, mingo@kernel.org, hpa@zytor.com, srivatsa.bhat@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Fri, 19 Apr 2013 14:23:23 +0900 Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:

> When booting x86 system contains memoryless node, node numbers of CPUs
> on memoryless node were changed to nearest online node number by
> init_cpu_to_node() because the node is not online.
> 
> ...
>
> If we hot add memory to memoryless node and offine/online all CPUs on
> the node, node numbers of these CPUs are changed to correct node numbers
> by srat_detect_node() because the node become online.

OK, here's a dumb question.

At boot time the CPUs are assigned to the "nearest online node" rather
than to their real memoryless node.  The patch arranges for those CPUs
to still be assigned to the "nearest online node" _after_ some memory
is hot-added to their real node.  Correct?

Would it not be better to fix this by assigning those CPUs to their real,
memoryless node right at the initial boot?  Or is there something in
the kernel which makes cpus-on-a-memoryless-node not work correctly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
