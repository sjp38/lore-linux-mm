Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 582456B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 01:20:49 -0500 (EST)
Received: by ggnf1 with SMTP id f1so3453558ggn.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 22:20:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1202131706320.30721@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1202131706320.30721@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 14 Feb 2012 01:20:28 -0500
Message-ID: <CAHGf_=o+-OdCp-vks1UV1pBAvhgNC=xD8Q2GyeLyQi6xAYkXKQ@mail.gmail.com>
Subject: Re: [patch -mm] mm, oom: introduce independent oom killer ratelimit state
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

2012/2/13 David Rientjes <rientjes@google.com>:
> printk_ratelimit() uses the global ratelimit state for all printks. =A0Th=
e
> oom killer should not be subjected to this state just because another
> subsystem or driver may be flooding the kernel log.
>
> This patch introduces printk ratelimiting specifically for the oom
> killer.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
