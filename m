Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E09348D0001
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 21:01:52 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAS21n30001849
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 18:01:49 -0800
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz24.hot.corp.google.com with ESMTP id oAS21THB012431
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 18:01:48 -0800
Received: by pwj4 with SMTP id 4so578262pwj.10
        for <linux-mm@kvack.org>; Sat, 27 Nov 2010 18:01:48 -0800 (PST)
Date: Sat, 27 Nov 2010 18:01:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm: add node hotplug emulation
In-Reply-To: <20101124064516.GA6777@shaohui>
Message-ID: <alpine.DEB.2.00.1011271800240.3764@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF28723FC4A7@shsmsx502.ccr.corp.intel.com> <20101122014706.GB9081@shaohui> <20101124064516.GA6777@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, gregkh@suse.de, mingo@redhat.com, hpa@zytor.com, tglx@linutronix.de, lethal@linux-sh.org, ak@linux.intel.com, yinghai@kernel.org, randy.dunlap@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, haicheng.li@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 24 Nov 2010, Shaohui Zheng wrote:

> ah, a long time silence.
> 

Sorry, last week included a holiday in the USA.

> Does somebody know the status of this patch, is it accepted by the maintainer?
> I am not in patch's CC list, so I will not get mail notice when the patch was
> accepted by the maintainer.
> 

Neither of these patches have been merged anywhere yet, you're not missing 
anything :)  If/when Andrew picks it up, I'm quite certain he'll cc you on 
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
