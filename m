Date: Wed, 27 Feb 2008 10:30:55 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
Message-ID: <20080227103055.2267b50c@bree.surriel.com>
In-Reply-To: <alpine.DEB.1.00.0802262315030.11433@chino.kir.corp.google.com>
References: <47C4F9C0.5010607@linux.vnet.ibm.com>
	<alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
	<20080227160746.425E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.1.00.0802262315030.11433@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008 23:19:08 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> My suggestion is merely to make the number of concurrent page reclaim 
> threads be a function of how many online cpus there are.

The more CPUs there are, the more lock contention you want?

Somehow that seems backwards :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
