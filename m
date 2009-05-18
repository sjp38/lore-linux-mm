Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2A7AB6B0055
	for <linux-mm@kvack.org>; Mon, 18 May 2009 07:44:16 -0400 (EDT)
Date: Mon, 18 May 2009 20:44:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] object collection tracing (was: [PATCH 5/5] proc: export more page flags in /proc/kpageflags)
In-Reply-To: <20090517133659.GD3254@localhost>
References: <20090512130110.GA6255@nowhere> <20090517133659.GD3254@localhost>
Message-Id: <20090518204242.0A07.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Tom Zanussi <tzanussi@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Steven Rostedt <rostedt@goodmis.org>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi


> > Could you send us the (sob'ed) patch you made which implements this.
> > I could try to adapt it to object collection.
> 
> Attached for your reference. Be aware that I still have plans to
> change it in non trivial way, and there are ongoing works by Nick(on
> inode_lock) and Jens(on s_dirty) that can create merge conflicts.
> So basically it is not a right time to do the adaption.

if you can make object collection based filecache viewer, could you
please cc me? I guess I can review it in mm part.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
