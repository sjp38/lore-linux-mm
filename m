Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 3480A6B004F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:11:44 -0500 (EST)
Received: by yenq10 with SMTP id q10so4240477yen.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 08:11:43 -0800 (PST)
Message-ID: <4EEF6240.9020107@gmail.com>
Date: Mon, 19 Dec 2011 11:11:44 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
In-Reply-To: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?B?QXJ2ZSBIag==?= =?UTF-8?B?w7hubmV2w6Vn?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> - Use memory controller cgroup (CGROUP_MEM_RES_CTLR) notifications from
>    the kernel side, plus userland "manager" that would kill applications.
>
>    The main downside of this approach is that mem_cg needs 20 bytes per
>    page (on a 32 bit machine). So on a 32 bit machine with 4K pages
>    that's approx. 0.5% of RAM, or, in other words, 5MB on a 1GB machine.
>
>    0.5% doesn't sound too bad, but 5MB does, quite a little bit. So,
>    mem_cg feels like an overkill for this simple task (see the driver at
>    the very bottom).

Kamezawa-san, Is 20bytes/page still correct now? If I remember 
correctly, you improved space efficiency of memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
