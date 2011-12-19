Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D85356B004F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 12:34:23 -0500 (EST)
Received: by yhgm50 with SMTP id m50so2936606yhg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:34:23 -0800 (PST)
Message-ID: <4EEF75A0.2080503@gmail.com>
Date: Mon, 19 Dec 2011 12:34:24 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <4EEF74AC.1060503@gmail.com>
In-Reply-To: <4EEF74AC.1060503@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?B?QXJ2ZSBIag==?= =?UTF-8?B?w7hubmV2w6Vn?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>> + read_lock(&tasklist_lock);
>
> Crazy inefficient. mere slab shrinker shouldn't take tasklist_lock.
> Imagine if tasks are much plenty...
>
> Moreover, if system have plenty file cache, any process shouldn't killed
> at all! That's fundamental downside of this patch.

In addition, this code is reused a lot of code of oom-killer. But it is 
bad idea. oom killer is really exceptional case. then it don't pay 
attention faster processing. But, no free memory is not rare. we don't 
have much free memory EVERY TIME. because we have file cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
