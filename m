Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0A0E36B004D
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 21:01:17 -0500 (EST)
Received: by bwz7 with SMTP id 7so135384bwz.6
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 17:56:47 -0800 (PST)
Message-ID: <4B0F31DB.6020009@gmail.com>
Date: Fri, 27 Nov 2009 02:56:43 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>	<alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>	<abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>	<20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>	<alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>	<20091125124433.GB27615@random.random>	<4B0DC764.8040205@gmail.com> <20091126103234.806a4982.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091126103234.806a4982.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> On Thu, 26 Nov 2009 01:10:12 +0100
> Vedran FuraA? <vedran.furac@gmail.com> wrote:
> 
>> Andrea Arcangeli wrote:
>>
>>> lengthy discussion on something I think is quite obviously better and
>>> I tried to change a couple of years back already (rss instead of
>>> total_vm).
>> Now that 2.6.32 is almost out, is it possible to get OOMK fixed in
>> 2.6.33 so that I could turn overcommit on (overcommit_memory=0) again
>> without fear of loosing my work?
>>
> I'll try fork-bomb detector again. That will finally help your X.org.
> But It may lose 2.6.33.
> 
> Adding new counter to mm_struct is now rejected because of scalability, so
> total work will need more time (than expected).
> I'm sorry I can't get enough time in these weeks.

Thanks for working on this! Hope it gets into 33. Keep me posted.

Regards,

Vedran


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
