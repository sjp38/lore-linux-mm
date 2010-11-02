Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7903C6B0155
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 23:33:20 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oA23XH5w013325
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 20:33:17 -0700
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by hpaq14.eem.corp.google.com with ESMTP id oA23XFa6029385
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 20:33:15 -0700
Received: by pwj2 with SMTP id 2so1510951pwj.8
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 20:33:14 -0700 (PDT)
Date: Mon, 1 Nov 2010 20:33:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add Kconfig option for default swappiness
In-Reply-To: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
Message-ID: <alpine.DEB.2.00.1011012030100.12298@chino.kir.corp.google.com>
References: <1288668052-32036-1-git-send-email-bgamari.foss@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Juhl <jj@chaosbits.net>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010, Ben Gamari wrote:

> This will allow distributions to tune this important vm parameter in a more
> self-contained manner.
> 

And they can't use an init script to tune /proc/sys/vm/swappiness 
because...?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
