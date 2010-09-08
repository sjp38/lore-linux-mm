Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3D06B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 23:28:46 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o883SiYx002594
	for <linux-mm@kvack.org>; Tue, 7 Sep 2010 20:28:44 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by kpbe19.cbf.corp.google.com with ESMTP id o883ShBD024932
	for <linux-mm@kvack.org>; Tue, 7 Sep 2010 20:28:43 -0700
Received: by pvg7 with SMTP id 7so2043092pvg.3
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 20:28:42 -0700 (PDT)
Date: Tue, 7 Sep 2010 20:28:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 2/2] oom: use old_mm for oom_disable_count in exec
In-Reply-To: <20100907102532.C8EC.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009072025360.4790@chino.kir.corp.google.com>
References: <20100902092039.D05C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011748190.22920@chino.kir.corp.google.com> <20100907102532.C8EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Sep 2010, KOSAKI Motohiro wrote:

> Don't mind. but general warning: If you continue to crappy objection, We
> are going to revert full of your userland breakage entirely instead minimum fix. 
> 

I'm not in the business of responding to your threats.  Unfortunately for 
your argument, you cannot cite a single example of a current user of 
/proc/pid/oom_adj that considers either (i) expected memory usage of the 
task, or (ii) system RAM capcacity, which would be required for that value 
to make any sense given the current implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
