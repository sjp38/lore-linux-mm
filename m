Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88B128D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:45:18 -0400 (EDT)
Received: by wwi36 with SMTP id 36so641496wwi.26
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 06:45:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
Date: Fri, 25 Mar 2011 09:45:15 -0400
Message-ID: <AANLkTin51sZ2fsOzfaSWQCWkrQ+JkyVWNnM022E2GFwQ@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Colin Walters <walters@verbum.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

Is there anything here that couldn't be solved with a proper cgroups
configuration?  In fact, wasn't this type of problem the original
cgroups motivation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
