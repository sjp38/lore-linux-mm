Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E6016B0093
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 20:45:28 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so1434026fga.8
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:45:26 -0700 (PDT)
Message-ID: <4AE79422.8010704@gmail.com>
Date: Wed, 28 Oct 2009 01:45:22 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
 RSS/swap value for oom_score (Re: Memory overcommit
References: <4ADE3121.6090407@gmail.com>	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>	<4AE5CB4E.4090504@gmail.com>	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>	<2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com>	<20091027153429.b36866c4.minchan.kim@barrios-desktop>	<20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com>	<28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com>	<20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com>	<20091027165612.4122d600.minchan.kim@barrios-desktop>	<20091027123810.GA22830@random.random> <20091028092251.8ddd1b20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091028092251.8ddd1b20.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

 > Hmm, maybe
>    anon_rss + file_rss/2 + swap_usage/4 + kosaki's time accounting change
> can give us some better value. I'll consider what number is logical and
> technically correct, again.

Although my vote doesn't count, from my experience, this formula sounds
like optimal solution. Thanks, hope it gets accepted!

Regards,

Vedran


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
