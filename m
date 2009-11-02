Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A26796B0089
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:55:59 -0500 (EST)
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size
  for badness
Received: by bwz7 with SMTP id 7so7287751bwz.6
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 11:55:57 -0800 (PST)
Message-ID: <4AEF394A.4050102@gmail.com>
Date: Mon, 02 Nov 2009 20:55:54 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>	 <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>	 <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>	 <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>	 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>	 <2f11576a0911010529t688ed152qbb72c87c85869c45@mail.gmail.com>	 <alpine.DEB.2.00.0911020237440.13146@chino.kir.corp.google.com> <2f11576a0911020435n103538d0p9d2afed4d39b4726@mail.gmail.com>
In-Reply-To: <2f11576a0911020435n103538d0p9d2afed4d39b4726@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> Oh, I'm sorry. I mesured with rss patch.
> Then, I haven't understand what makes Xorg bad score.
> 
> Hmm...
> Vedran,  Can you please post following command result?
> 
> # cat /proc/`pidof Xorg`/smaps
> 
> I hope to undestand the issue clearly before modify any code.


No problem:

http://pastebin.com/d66972025 (long)

Xorg is from debian unstable.

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
