Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4CB286B004D
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 14:16:15 -0500 (EST)
Received: by bwz7 with SMTP id 7so2430519bwz.6
        for <linux-mm@kvack.org>; Sat, 07 Nov 2009 11:16:13 -0800 (PST)
Message-ID: <4AF5C779.7000909@gmail.com>
Date: Sat, 07 Nov 2009 20:16:09 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
References: <2f11576a0911020435n103538d0p9d2afed4d39b4726@mail.gmail.com> <4AEF394A.4050102@gmail.com> <20091104002903.0B4D.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091104002903.0B4D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> Your Xorg have pretty large heap. I'm not sure why it happen. (ATI
> video card issue?)

It is ATI (fglrx), but I don't know if it is driver's issue or not. I
have a lot of apps running, firefox with high number of tabs and so on.
It adds up probably.

> Unfortunatelly, It is showed as normal large heap from kernel. then, 
> I doubt kernel can distinguish X from other process. Probably oom-adj
> is most reasonable option....
>
> -------------------------------------------------
> [heap]
> Size:             433812 kB
> Rss:              433304 kB
> Pss:              433304 kB
> Shared_Clean:          0 kB
> Shared_Dirty:          0 kB
> Private_Clean:       280 kB
> Private_Dirty:    433024 kB
> Referenced:       415656 kB
> Swap:                  0 kB
> KernelPageSize:        4 kB
> MMUPageSize:           4 kB



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
