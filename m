Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D0896B00B6
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:36:52 -0400 (EDT)
Received: by gxk12 with SMTP id 12so4750261gxk.4
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:36:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090825183734.1b2d0559.kamezawa.hiroyu@jp.fujitsu.com>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
	 <28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
	 <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
	 <2f11576a0908232113w71676aatf22eb6d431501fd0@mail.gmail.com>
	 <82e12e5f0908242146uad0f314hcbb02fcc999a1d32@mail.gmail.com>
	 <Pine.LNX.4.64.0908250947400.2872@sister.anvils>
	 <20090825183734.1b2d0559.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 25 Aug 2009 20:46:07 +0900
Message-ID: <28c262360908250446g5ab88437oab0eec4b1fb7df53@mail.gmail.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Hiroaki Wakabayashi <primulaelatior@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 6:37 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 25 Aug 2009 10:03:30 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
>> My advice (but I sure hate giving advice before I've tried it myself)
>> is to put __mlock_vma_pages_range() back to handling just the mlock
>> case, and do your own follow_page() loop in munlock_vma_pages_range().
>>
>
> I have no objections to make use of follow_page().

Me, too.
We don't need to add new flag although there is simple method like this.

> Thanks,
> -Kame
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
