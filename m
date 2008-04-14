Message-ID: <480310C5.1070102@cn.fujitsu.com>
Date: Mon, 14 Apr 2008 16:07:33 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix oops in oom handling
References: <4802FF10.6030905@cn.fujitsu.com>	 <20080414161428.27f3ee59.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830804140053y4bcdceeatc9763c1e8c1aaf44@mail.gmail.com>
In-Reply-To: <6599ad830804140053y4bcdceeatc9763c1e8c1aaf44@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Apr 14, 2008 at 12:14 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>  Paul, I have one confirmation. Lock hierarchy of
>>         cgroup_lock()
>>         ->      read_lock(&tasklist_lock)
>>
>>  is ok ? (I think this is ok.)
> 
> Should be fine, I think.
> 
> Have you built/booted with lockdep?
> 

I should have done this. :(

I'll check it.

> Paul
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
