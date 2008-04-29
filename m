Date: Tue, 29 Apr 2008 12:11:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/8] memcg: optimize branches
Message-Id: <20080429121132.effa56ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080429114832.dc446b4a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
	<20080428202810.a8de4468.kamezawa.hiroyu@jp.fujitsu.com>
	<4816823D.8000101@cn.fujitsu.com>
	<20080429114832.dc446b4a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008 11:48:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> extern void *allocalter(int size);
> extern void call(int arg);
> void *foo(void)
> {
>         char *ptr;
>         ptr = allocator(1024);
>         if (unlikely(!ptr)) {
>                 call(1);
>                 call(2);
>         } else {
>                 call(3);
>                 call(4);
>         }
>         return ptr;
> }
> ==
> When I compiled above with -O2 on ia64,
>  - if unlikely is used , call(3),call(4) are on fast path.
>  - if unlikely is not used, call(1), call(3) are on fast path.
                                       call(2)
Sorry, too many typos in these days ...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
