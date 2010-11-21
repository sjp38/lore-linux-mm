Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0336A6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 09:23:11 -0500 (EST)
Received: by pzk30 with SMTP id 30so1272441pzk.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 06:23:09 -0800 (PST)
Date: Sun, 21 Nov 2010 22:26:15 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch 1/2] x86: add numa=possible command line option
Message-ID: <20101121142615.GI9099@hack>
References: <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com> <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@suse.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Hi, David

On Sat, Nov 20, 2010 at 06:28:31PM -0800, David Rientjes wrote:
>Adds a numa=possible=<N> command line option to set an additional N nodes
>as being possible for memory hotplug.  This set of possible nodes
>controls nr_node_ids and the sizes of several dynamically allocated node
>arrays.
>
>This allows memory hotplug to create new nodes for newly added memory
>rather than binding it to existing nodes.
>
>The first use-case for this will be node hotplug emulation which will use
>these possible nodes to create new nodes to test the memory hotplug
>callbacks and surrounding memory hotplug code.
>


I am not sure how much value of making this dynamic,
for CPU, we do this at compile time, i.e. NR_CPUS,
so how about NR_NODES?

Also, numa=possible= is not as clear as numa=max=, for me at least.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
