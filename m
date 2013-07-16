Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 17B7D6B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 00:26:40 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id jg1so64999bkc.6
        for <linux-mm@kvack.org>; Mon, 15 Jul 2013 21:26:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHH2K0avjz=H8k2zo-P-QJt=9f61GoAmq+ceECzGNxdUx1PWbA@mail.gmail.com>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
	<1373045623-27712-1-git-send-email-handai.szj@taobao.com>
	<20130711145625.GK21667@dhcp22.suse.cz>
	<CAHH2K0avjz=H8k2zo-P-QJt=9f61GoAmq+ceECzGNxdUx1PWbA@mail.gmail.com>
Date: Tue, 16 Jul 2013 12:26:38 +0800
Message-ID: <CAFj3OHX5cRZTyi-xXJHGOrkE8CbnJ0KFkEfB3FUuOr7bk+fWWQ@mail.gmail.com>
Subject: Re: [PATCH V4 5/6] memcg: patch mem_cgroup_{begin,end}_update_page_stat()
 out if only root memcg exists
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, Sha Zhengju <handai.szj@taobao.com>

On Tue, Jul 16, 2013 at 1:58 AM, Greg Thelen <gthelen@google.com> wrote:
> On Thu, Jul 11, 2013 at 7:56 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> On Sat 06-07-13 01:33:43, Sha Zhengju wrote:
>>> From: Sha Zhengju <handai.szj@taobao.com>
>>>
>>> If memcg is enabled and no non-root memcg exists, all allocated
>>> pages belongs to root_mem_cgroup and wil go through root memcg
>>> statistics routines.  So in order to reduce overheads after adding
>>> memcg dirty/writeback accounting in hot paths, we use jump label to
>>> patch mem_cgroup_{begin,end}_update_page_stat() in or out when not
>>> used.
>>
>> I do not think this is enough. How much do you save? One atomic read.
>> This doesn't seem like a killer.
>
> Given we're already using mem_cgroup_{begin,end}_update_page_stat(),
> this optimization seems independent of memcg dirty/writeback
> accounting.  Does this patch help memcg even before dirty/writeback
> accounting?  If yes, then we have the option of splitting this
> optimization out of the series.

Set_page_dirty is a hot path, people said I should be careful to the
overhead of adding a new counting, and the optimization is a must
before merging.
But since we have more need of this feature now, if it's blocking
something, I'm willing to split it.

--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
