Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2A77A6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:46:16 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oALLkDHe027166
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:46:13 -0800
Received: from gyd8 (gyd8.prod.google.com [10.243.49.200])
	by kpbe18.cbf.corp.google.com with ESMTP id oALLkBgj020417
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:46:12 -0800
Received: by gyd8 with SMTP id 8so4036797gyd.23
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:46:11 -0800 (PST)
Date: Sun, 21 Nov 2010 13:46:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] x86: add numa=possible command line option
In-Reply-To: <20101121142615.GI9099@hack>
Message-ID: <alpine.DEB.2.00.1011211343350.26304@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com> <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org>
 <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
 <20101121142615.GI9099@hack>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531368966-2030196969-1290375970=:26304"
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@suse.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531368966-2030196969-1290375970=:26304
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sun, 21 Nov 2010, AmA(C)rico Wang wrote:

> I am not sure how much value of making this dynamic,
> for CPU, we do this at compile time, i.e. NR_CPUS,
> so how about NR_NODES?
> 

This is outside the scope of node hotplug emulation, it needs to be built 
on top of whatever the kernel implements.

> Also, numa=possible= is not as clear as numa=max=, for me at least.
> 

I like name, but it requires that you know how many nodes that system 
already has.  In other words, numa=possible=4 allows you to specify that 4 
additional nodes will be possible, but initially offline, for this or 
other purposes.  numa=max=4 would be no-op if the system actually had 4 
nodes.

I chose numa=possible over numa=additional because it is more clearly tied 
to node_possible_map, which is the only thing it modifies.
--531368966-2030196969-1290375970=:26304--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
