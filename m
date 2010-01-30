Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D9B326B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 12:44:19 -0500 (EST)
Date: Sat, 30 Jan 2010 17:45:16 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-ID: <20100130174516.2257d7fa@lxorguk.ukuu.org.uk>
In-Reply-To: <4B646CBE.6050404@gmail.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
	<4B622AEE.3080906@gmail.com>
	<20100129003547.521a1da9@lxorguk.ukuu.org.uk>
	<4B62327F.3010208@gmail.com>
	<20100129110321.564cb866@lxorguk.ukuu.org.uk>
	<4B64272D.8020509@gmail.com>
	<20100130125917.600beb51@lxorguk.ukuu.org.uk>
	<4B646CBE.6050404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> I can't say I'm able to correctly read kernel code, but I believe
> default is set by:

It['s set by the distribution - the kerne has a default value but given
the same distributions are shipping the crap userspace that breaks with
no-overcommit do you think they'll set it to break their user apps ?

No.

> http://vedranf.net/tmp/oom.ogv  (you can watch it using VLC for example)
> 
> Actually anyone receiving this mail should see it. What do you think,
> what will customers rather choose if they see this?

Address that to the distributions. Their customers. Systems I set up for
people always have no overcommit enabled.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
