Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E243D6B0085
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:04:54 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oAU04ov5029220
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:51 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz17.hot.corp.google.com with ESMTP id oAU04kI3018382
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:49 -0800
Received: by pwj4 with SMTP id 4so1227165pwj.24
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:04:48 -0800 (PST)
Date: Mon, 29 Nov 2010 16:04:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2 v2] mm: add node hotplug emulation
In-Reply-To: <20101128051749.GA11474@suse.de>
Message-ID: <alpine.DEB.2.00.1011291602560.21653@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011201827540.12889@chino.kir.corp.google.com> <20101121173438.GA3922@suse.de> <alpine.DEB.2.00.1011211346160.26304@chino.kir.corp.google.com> <alpine.DEB.2.00.1011211505440.30377@chino.kir.corp.google.com> <20101122005658.GA6710@suse.de>
 <alpine.DEB.2.00.1011271750140.3764@chino.kir.corp.google.com> <20101128051749.GA11474@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Nov 2010, Greg KH wrote:

> Then name it as such, not the generic "hotplug" like you just did.
> "mem_hotplug" would make sense, right?
> 

Ok, Shaohui has taken my patches to post as part of the larger series and 
I requested that the interface be changed from s/hotplug/mem_hotplug as 
you suggested (and you should be cc'd).  I agree it's a better name to 
isolate memory hotplug debugging triggers from others.

Thanks Greg!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
