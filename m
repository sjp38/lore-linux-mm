Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4FC306B006A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 07:35:37 -0500 (EST)
Received: by iwn5 with SMTP id 5so3305607iwn.11
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 04:35:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0911020237440.13146@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	 <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
	 <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
	 <2f11576a0911010529t688ed152qbb72c87c85869c45@mail.gmail.com>
	 <alpine.DEB.2.00.0911020237440.13146@chino.kir.corp.google.com>
Date: Mon, 2 Nov 2009 21:35:35 +0900
Message-ID: <2f11576a0911020435n103538d0p9d2afed4d39b4726@mail.gmail.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

>> Hi David,
>>
>> I'm very interesting your pointing out. thanks good testing.
>> So, I'd like to clarify your point a bit.
>>
>> following are badness list on my desktop environment (x86_64 6GB mem).
>> it show Xorg have pretty small badness score. Do you know why such
>> different happen?
>
> I don't know specifically what's different on your machine than Vedran's,
> my data is simply a collection of the /proc/sys/vm/oom_dump_tasks output
> from Vedran's oom log.
>
> I guess we could add a call to badness() for the oom_dump_tasks tasklist
> dump to get a clearer picture so we know the score for each thread group
> leader.  Anything else would be speculation at this point, though.
>
>> score    pid        comm
>> ==============================
>> 56382   3241    run-mozilla.sh
>> 23345   3289    run-mozilla.sh
>> 21461   3050    gnome-do
>> 20079   2867    gnome-session
>> 14016   3258    firefox
>> 9212    3306    firefox
>> 8468    3115    gnome-do
>> 6902    3325    emacs
>> 6783    3212    tomboy
>> 4865    2968    python
>> 4861    2948    nautilus
>> 4221    1       init
>> (snip about 100line)
>> 548     2590    Xorg
>>
>
> Are these scores with your rss patch or without?  If it's without the
> patch, this is understandable since Xorg didn't appear highly in Vedran's
> log either.

Oh, I'm sorry. I mesured with rss patch.
Then, I haven't understand what makes Xorg bad score.

Hmm...
Vedran,  Can you please post following command result?

# cat /proc/`pidof Xorg`/smaps


I hope to undestand the issue clearly before modify any code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
