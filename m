Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0D3566B0092
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:25:24 -0500 (EST)
Received: by fxm9 with SMTP id 9so1403551fxm.10
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:25:23 -0800 (PST)
Message-ID: <4B622AEE.3080906@gmail.com>
Date: Fri, 29 Jan 2010 01:25:18 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>	<20100126151202.75bd9347.akpm@linux-foundation.org>	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>	<20100126161952.ee267d1c.akpm@linux-foundation.org>	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com> <20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
In-Reply-To: <20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:

> Am I missing something fundamental here ?

Yes, the fact linux mm currently sucks. How else would you explain
possibility of killing random (often root owned) processes using a 5
lines program started by an ordinary user? Killed process could be an
apache web server or X server on a desktop. I demonstrated this flaw few
months ago here and only Kame tried to find a way to fix it but
encountered noncooperation.

I don't know what to say, really. Sad... Actually funny, when you know
that competition OS, often ridiculed by linux users, doesn't suffer any
consequences when that same 5 line program is run.

Regards,
Vedran


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
