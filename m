Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0941C9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 17:09:26 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p5KL9Nwr007775
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 14:09:23 -0700
Received: from pvf24 (pvf24.prod.google.com [10.241.210.88])
	by hpaq14.eem.corp.google.com with ESMTP id p5KL9CAL004145
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 14:09:21 -0700
Received: by pvf24 with SMTP id 24so1392799pvf.20
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 14:09:21 -0700 (PDT)
Date: Mon, 20 Jun 2011 14:09:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add uid to "Killed process" message
In-Reply-To: <1308567876-23581-1-git-send-email-fhrbata@redhat.com>
Message-ID: <alpine.DEB.2.00.1106201409090.2639@chino.kir.corp.google.com>
References: <1308567876-23581-1-git-send-email-fhrbata@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, lwoodman@redhat.com

On Mon, 20 Jun 2011, Frantisek Hrbata wrote:

> Add user id to the oom killer's "Killed process" message, so the user of the
> killed process can be identified.
> 

Notified in what way?  Unless you are using the memory controller, there's 
no userspace notification that an oom event has happened so nothing would 
know to scrape the kernel log for this information.

We've had a long-time desire for an oom notifier, not only at the time of 
oom but when approaching it with configurable thresholds, that would 
wakeup a userspace daemon that might be polling on notifier.  That seems 
more useful for realtime notification of an oom event rather than relying 
on the kernel log?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
