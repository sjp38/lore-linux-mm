Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E06A88D0040
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 14:45:18 -0400 (EDT)
Date: Sun, 3 Apr 2011 13:45:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110403184514.AE4E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104031342540.15317@router.home>
References: <20110401221921.A890.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104010945190.17929@router.home> <20110403184514.AE4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

On Sun, 3 Apr 2011, KOSAKI Motohiro wrote:

> 1) Some bios don't have such knob. btw, OK, yes, *I* can switch NUMA off completely
> because I don't have such bios. 2) bios level turning off makes some side effects,
> example, scheduler load balancing don't care numa anymore.

Well then lets add a kernel parameter that switches all NUMA off.
Otherwise: If you just run a kernel build without NUMA support then you have a similar
effect.

Re #2) If you have the system toss processes around the system then the
load balancing heuristics does not bring you any benefit.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
