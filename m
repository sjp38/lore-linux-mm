Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A29EE6B0093
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 19:10:17 -0500 (EST)
Received: by bwz7 with SMTP id 7so224295bwz.6
        for <linux-mm@kvack.org>; Wed, 25 Nov 2009 16:10:15 -0800 (PST)
Message-ID: <4B0DC764.8040205@gmail.com>
Date: Thu, 26 Nov 2009 01:10:12 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com> <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com> <20091125124433.GB27615@random.random>
In-Reply-To: <20091125124433.GB27615@random.random>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> Hello,

Hi all!

> lengthy discussion on something I think is quite obviously better and
> I tried to change a couple of years back already (rss instead of
> total_vm).

Now that 2.6.32 is almost out, is it possible to get OOMK fixed in
2.6.33 so that I could turn overcommit on (overcommit_memory=0) again
without fear of loosing my work?

Regards,

Vedran


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
