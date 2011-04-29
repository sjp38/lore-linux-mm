Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 01175900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:58:42 -0400 (EDT)
Date: Fri, 29 Apr 2011 10:58:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110429025838.GA13150@localhost>
References: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110429022824.GA8061@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

Andrew,

I tested the more realistic 100 dd case. The results are

- nr_alloc_fail: 892 => 146
- reclaim delay: 4ms => 68ms

Thanks,
Fengguang
---

base kernel, 100 dd
-------------------

start time: 3
total time: 52
nr_alloc_fail 892
allocstall 131341

2nd run (no reboot):

start time: 3
total time: 53
nr_alloc_fail 1555
allocstall 265718


CPU             count     real total  virtual total    delay total
                  962     3125524848     3113269116    37972729582
IO              count    delay total  delay average
                    3       25204838              8ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average    
                 1032     5130797747              4ms  

(IPIs accumulated in two runs)
CAL:      34898      35428      35182      35553      35320      35291      35298      35102   Function call interrupts

10ms limit, 100 dd
------------------

start time: 2
total time: 50
nr_alloc_fail 146
allocstall 10598

CPU             count     real total  virtual total    delay total
                 1038     3349490800     3331087137    40156395960
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                   84     5795410854             68ms
dd: read=0, write=0, cancelled_write=0

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
