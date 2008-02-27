Date: Wed, 27 Feb 2008 16:10:57 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
References: <47C4F9C0.5010607@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
Message-Id: <20080227160746.425E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

> Adding yet another sysctl for this functionality seems unnecessary, unless 
> it is attempting to address other VM problems where page reclaim needs to 
> be throttled when it is being stressed.  Those issues need to be addressed 
> directly, in my opinion, instead of attempting to workaround it by 
> limiting the number of concurrent reclaim threads.

hm,

could you post another patch?
I hope avoid implementless discussion.
and I hope compare by benchmark result.


-kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
