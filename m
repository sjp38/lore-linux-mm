Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BBA386B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:16:20 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oB8LGIua031000
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 13:16:18 -0800
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz21.hot.corp.google.com with ESMTP id oB8LGElD023117
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 13:16:17 -0800
Received: by pvc30 with SMTP id 30so515242pvc.0
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 13:16:14 -0800 (PST)
Date: Wed, 8 Dec 2010 13:16:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
In-Reply-To: <20101208181644.GA2152@mgebm.net>
Message-ID: <alpine.DEB.2.00.1012081315040.15658@chino.kir.corp.google.com>
References: <20101207010033.280301752@intel.com> <20101207010139.681125359@intel.com> <20101207182420.GA2038@mgebm.net> <20101207232000.GA5353@shaohui> <20101208181644.GA2152@mgebm.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: Shaohui Zheng <shaohui.zheng@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 2010, Eric B Munson wrote:

> Shaohui,
> 
> I was able to online a cpu to node 0 successfully.  My problem was that I did
> not take the cpu offline before I released it.  Everything looks to be working
> for me.
> 

I think it should fail more gracefully than triggering WARN_ON()s because 
of duplicate sysfs dentries though, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
