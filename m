Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 282FB8D0001
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 20:52:13 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oAS1q8kX026136
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:52:09 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz1.hot.corp.google.com with ESMTP id oAS1q73K015271
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:52:07 -0800
Received: by pwj4 with SMTP id 4so759086pwj.38
        for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:52:06 -0800 (PST)
Date: Sat, 27 Nov 2010 17:52:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2 v2] mm: add node hotplug emulation
In-Reply-To: <20101122005658.GA6710@suse.de>
Message-ID: <alpine.DEB.2.00.1011271750140.3764@chino.kir.corp.google.com>
References: <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201827540.12889@chino.kir.corp.google.com> <20101121173438.GA3922@suse.de> <alpine.DEB.2.00.1011211346160.26304@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011211505440.30377@chino.kir.corp.google.com> <20101122005658.GA6710@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2010, Greg KH wrote:

> > Add an interface to allow new nodes to be added when performing memory
> > hot-add.  This provides a convenient interface to test memory hotplug
> > notifier callbacks and surrounding hotplug code when new nodes are
> > onlined without actually having a machine with such hotpluggable SRAT
> > entries.
> > 
> > This adds a new debugfs interface at /sys/kernel/debug/hotplug/add_node
> 
> The rule for debugfs is "there are no rules", but perhaps you might want
> to name "hotplug" a bit more specific for what you are doing?  "hotplug"
> means pretty much anything these days, so how about s/hotplug/node/
> instead as that is what you are controlling.
> 
> Just a suggestion...
> 

Hmm, how strongly do you feel about that?  There's nothing node specific 
in the memory hotplug code where this lives, so we'd probably have to 
define the dentry elsewhere and even then it would only needed for 
CONFIG_MEMORY_HOTPLUG.

I personally don't see this as a node debugging but rather memory hotplug 
callback debugging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
