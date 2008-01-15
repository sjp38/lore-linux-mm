Date: Tue, 15 Jan 2008 11:20:56 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <20080115111035.d516639a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115111035.d516639a.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080115110918.118B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Kame

> > +	if (pressure) {
> > +		nr_wakeup = max_t(int, atomic_read(&nr_watcher_task)>>4, 100);
> > +		atomic_long_set(&last_mem_notify, jiffies);
> > +		wake_up_locked_nr(&mem_wait, nr_wakeup);
> > +	}
> What is this for ? and Why ?
> Are there too many waiters ?

my intent is for avoid thundering herd.
100 is heuristic value.

and too many wakeup cause too much memory freed.
I don't want it.

of course, if any problem happened, I will change.
Do you dislike it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
