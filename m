Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4396B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 16:48:25 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oALLmMjI020920
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:48:23 -0800
Received: from gyb11 (gyb11.prod.google.com [10.243.49.75])
	by hpaq12.eem.corp.google.com with ESMTP id oALLmLsg020474
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:48:21 -0800
Received: by gyb11 with SMTP id 11so933681gyb.19
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 13:48:20 -0800 (PST)
Date: Sun, 21 Nov 2010 13:48:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm: add node hotplug emulation
In-Reply-To: <20101121173438.GA3922@suse.de>
Message-ID: <alpine.DEB.2.00.1011211346160.26304@chino.kir.corp.google.com>
References: <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com> <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com>
 <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com> <alpine.DEB.2.00.1011201827540.12889@chino.kir.corp.google.com> <20101121173438.GA3922@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Nov 2010, Greg KH wrote:

> But as this is a debugging thing, why not just put it in debugfs
> instead?
> 

Ok, I think Paul had a similar suggestion during the discussion of 
Shaohui's patchset.  I'll move it, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
