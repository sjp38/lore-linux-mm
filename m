Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6F1596B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 05:36:26 -0400 (EDT)
Message-ID: <513EF6F7.90002@huawei.com>
Date: Tue, 12 Mar 2013 17:35:51 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [BUG] potential deadlock led by cpu_hotplug lock (memcg involved)
References: <513ECCFE.3070201@huawei.com> <CAJd=RBB7GVp_Ry30SuZVa-FgOogEZ43UnXOGvVKesV=Qk96UDA@mail.gmail.com>
In-Reply-To: <CAJd=RBB7GVp_Ry30SuZVa-FgOogEZ43UnXOGvVKesV=Qk96UDA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On 2013/3/12 16:32, Hillf Danton wrote:
> On Tue, Mar 12, 2013 at 2:36 PM, Li Zefan <lizefan@huawei.com> wrote:
>> Seems a new bug in 3.9 kernel?
>>
> Bogus info, perhaps.
> 

No matter it's a real bug or it's false positive, we need to make
lockdep happy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
