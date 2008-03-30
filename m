Date: Sun, 30 Mar 2008 18:32:27 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][-mm][0/2] page reclaim throttle take4
In-Reply-To: <20080330172127.89DE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <47EF4B51.20204@linux.vnet.ibm.com> <20080330172127.89DE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080330182556.89E3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Hi balbir-san,

> > The results look quite impressive. Have you seen how your patches integrate with
> > Rik's LRU changes?
> 
> I am mesuring just now.
> I will be able to report about 2-3 days after.

btw: current roughly result.
     (# of mesurement is few, yet)

    num_group  2.6.25-rc5-mm1   throttle     throttle + split_lru
   --------------------------------------------------------------
     115            36.96        36.02            36.12
     125            41.07        38.88            38.29
     150           766.92       128.27           129.09




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
