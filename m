MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: kernel warning: tried to kill an mm-less task!
In-Reply-To: Oleg Nesterov's message of  Tuesday, 15 April 2008 10:17:16 +0400 <20080415061716.GA89@tv-sign.ru>
References: <4803030D.3070906@cn.fujitsu.com>
	<48030F69.7040801@linux.vnet.ibm.com>
	<48031090.5050002@cn.fujitsu.com>
	<48042539.8050009@cn.fujitsu.com>
	<20080415061716.GA89@tv-sign.ru>
Message-Id: <20080415205830.2BA4B26FA5E@magilla.localdomain>
Date: Tue, 15 Apr 2008 13:58:30 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

> Roland, what do you think about the coredump? Looks like we have the ancient
> bug, zap_threads() can hit the kernel thread.

I think you're right.  But I've never known much about the ->mm maintenance
code or the aio use_mm logic.  So I'm just going from a quick glance.
(That part of the zap_threads() logic predates you or I fiddling with it.)


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
