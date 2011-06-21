Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE5E90013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 15:08:04 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p5LJ7wre018709
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:08:01 -0700
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by hpaq5.eem.corp.google.com with ESMTP id p5LJ7Yqa014518
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:07:57 -0700
Received: by pzk10 with SMTP id 10so60717pzk.35
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 12:07:56 -0700 (PDT)
Date: Tue, 21 Jun 2011 12:07:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add uid to "Killed process" message
In-Reply-To: <20110621113629.GA2758@dhcp-26-164.brq.redhat.com>
Message-ID: <alpine.DEB.2.00.1106211205290.30481@chino.kir.corp.google.com>
References: <1308567876-23581-1-git-send-email-fhrbata@redhat.com> <alpine.DEB.2.00.1106201409090.2639@chino.kir.corp.google.com> <20110621113629.GA2758@dhcp-26-164.brq.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, lwoodman@redhat.com

On Tue, 21 Jun 2011, Frantisek Hrbata wrote:

> I guess the uid of the killed process can be identified from the dump_tasks
> output, where it is presented along with other info. I think it is handy
> to have the uid info directly in the "Killed process" message. 
> 
> This is used/requested by one of our customers and since I think it's a good
> idea to have the uid info presented, I posted the patch here to see what do you
> think about it.
> 

I don't feel strongly about it, but I think you could justify adding a lot 
of the same information from the tasklist dump to the single "Killed 
process" message.  The optimal way of getting this information would be 
from the tasklist dump.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
