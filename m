Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 469186B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:40:09 -0500 (EST)
Received: by gxk7 with SMTP id 7so4608358gxk.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 07:40:07 -0800 (PST)
Date: Mon, 22 Nov 2010 23:43:17 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch 1/2] x86: add numa=possible command line option
Message-ID: <20101122154317.GC4137@hack>
References: <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com> <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com> <20101121142615.GI9099@hack> <alpine.DEB.2.00.1011211343350.26304@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1011211343350.26304@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@suse.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 01:46:07PM -0800, David Rientjes wrote:
>On Sun, 21 Nov 2010, AmA(C)rico Wang wrote:
>> Also, numa=possible= is not as clear as numa=max=, for me at least.
>> 
>
>I like name, but it requires that you know how many nodes that system 
>already has.  In other words, numa=possible=4 allows you to specify that 4 
>additional nodes will be possible, but initially offline, for this or 
>other purposes.  numa=max=4 would be no-op if the system actually had 4 
>nodes.
>
>I chose numa=possible over numa=additional because it is more clearly tied 
>to node_possible_map, which is the only thing it modifies.

Okay, I thought "possible" means "max", but "possible" means "addtional" here.
It's clear for me now.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
