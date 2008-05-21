Date: Wed, 21 May 2008 15:06:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/3] memcg:: seq_ops support for cgroup
Message-Id: <20080521150629.c22cb81e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830805202206v334cb933t5b493988e01b3b21@mail.gmail.com>
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
	<20080520180841.f292beef.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830805201146g5a2a8928l6a2f5adc51b15f15@mail.gmail.com>
	<20080521092849.c2f0b7e1.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830805202206v334cb933t5b493988e01b3b21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008 22:06:48 -0700
"Paul Menage" <menage@google.com> wrote:

> >
> > And (*read) method isn't useful ;)
> >
> > Can we add new stat file dynamically ?
> 
> Yes, there's no reason we can't do that. Right now it's not possible
> to remove a control file without deleting the cgroup, but I have a
> patch that supports removal.
> 
Good news. I'll wait for.

> The question is whether it's better to have one file per CPU/node or
> one large complex file.
> 
For making the kernel simple, one-file-per-entity(cpu/node...) is better.
For making the applications simple, one big file is better.

I think recent interfaces uses one-file-per-entity method. So I vote for it
for this numastat. One concern is size of cpu/node. It can be 1024...4096 depends
on environment.

open/close 4096 files took some amount of cpu time.
(And that's why 'ps' command is slow on big system.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
