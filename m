Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 55EAF6B005C
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 13:51:22 -0500 (EST)
Received: by lagw12 with SMTP id w12so779983lag.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 10:51:20 -0800 (PST)
Date: Tue, 17 Jan 2012 20:51:13 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
In-Reply-To: <4F15A34F.40808@redhat.com>
Message-ID: <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com> <4F15A34F.40808@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hello,

Ok, so here's a proof of concept patch that implements sample-base 
per-process free threshold VM event watching using perf-like syscall ABI. 
I'd really like to see something like this that's much more extensible and 
clean than the /dev based ABIs that people have proposed so far.

 			Pekka

------------------->
